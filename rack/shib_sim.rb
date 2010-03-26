##
##

module Rack
  
  class ShibSim
  
    require 'haml'
    require 'haml/template'
    require 'yaml'
    require 'time'
    
    ##
    ## Setup views, default data, etc
    ##

    ## If no user created/edited files are present, use these from the gem
    DEFAULT_CONFIG = "#{::File.dirname(__FILE__)}/shib_sim/default_config/config.yml"
    DEFAULT_FILTER = "#{::File.dirname(__FILE__)}/shib_sim/default_config/record_filter.rb"
    
    ## These are the default locations of user-edited versions of the above files (Rails only at the moment)
    APP_CONFIG = RAILS_ROOT ? "#{RAILS_ROOT}/config/shibsim_config.yml" : DEFAULT_CONFIG
    APP_FILTER = RAILS_ROOT ? "#{RAILS_ROOT}/config/record_filter.rb"  : DEFAULT_FILTER
    
    ## Middleware application components and behaviour
    CONTENT_TYPE   = { "Content-Type" => "text/html; charset=utf-8" }
    VIEWS          = [:user_chooser, :fatal_error]
  
    def initialize(app, config_file_location=nil)
      
      ## Rack app
      @app = app
      
      ## Initial vars for storing cached data
      @views    = nil
      @users    = nil
      @orgtree  = nil 
      
      
      ## Load and cache the config file
      load_config_file(config_file_location)
      
      ## Add the record processing mixin if it's present
      load_filter_mixin
      
      ## Load and cache the data sources for users and chooser organisations
      user_data
      
      ## Load the Federation and IDP data
      # ...
      
      ## Check that everything is OK
      check_state
      
    end
  
    ## Selecting an action and returning to the Rack stack 
    def call(env)
    
      ## Peek at user input, they might be talking to us
      req = Rack::Request.new(env)
    
      begin
      
        ## Reset session?
        reset_session(env) if req.params['shibsim_reset']
  
        ## Already set? Then re-inject the headers (they are outside session)
        if env["rack.session"]['shibkit-sp_simulator'] and
          env["rack.session"]['shibkit-sp_simulator'][:userid]
        
          ## The user id
          user_id = env['rack.session']['shibkit-sp_simulator'][:userid]
          user_details = users[user_id.to_s]
          
          ## Add appropriate headers, etc
          set_session(env, user_details)
        
          ## Pass control up to higher Rack middleware and application
          return @app.call(env) 
        
        end

        ## Directly requested user or user? (via URL param)
        user_id = req.params['shibsim_user']

        ## Bodge session or display a page showing the list of available fixtures
        if user_id 
        
          ## Get our user information using the param
          user_details = users[user_id.to_s]
        
          ## A crude check that we've really found some attributes...
          if user_details and user_details.kind_of?(Hash) and
            user_details.size > 1 
          
            ## Update session, map data, then inject into headers
            set_session(env, user_details)
          
            ## Clean up
            tidy_request(env)

            return @app.call(env)
          
          else
      
            ## User was requested but no user details were found
            message = "User with ID '#{user_id}' could not be found!"

          end

          tidy_request(env)
        
          return user_chooser_action(env, { :message => message, :code => 401 })
        
        else
         
           ## No user requested, so show the chooser
           tidy_request(env)
           return user_chooser_action(env)
      
        end

      rescue => oops
      
        return fatal_error_action(env, oops)
    
      end

    end
  
    ##
    ##
    ##
  
    private
  
    ## Wipe clean the Rack session info for this middleware
    def reset_session(env)
 
      env["rack.session"]['shibkit-sp_simulator'] = Hash.new
    
      tidy_request(env)
    
    end

    ## Error page for unrecoverable situations
    def fatal_error_action(env, oops)
    
      unless ENV['RACK_ENV'] == :production or ENV['RAILS_ENV'] == :production
        puts "Shibkit Rack error: " + oops.to_s
        puts "Backtrace is:\n#{oops.backtrace.to_yaml}"
      end
    
      render_locals = { :message => oops.to_s }
      page_body = render_page(:fatal_error, render_locals)
    
      return 500, CONTENT_TYPE, [page_body.to_s]
    
    end
  
    ## Controller for user presentation page
    def user_chooser_action(env, options={}) 
    
       message = options[:message] 
       code    = options[:code].to_i || 200
    
       render_locals = { :organisations => organisations, :users => users, :message => message }
       page_body = render_page(:user_chooser, render_locals)
       
       return code, CONTENT_TYPE, [page_body.to_s]
    
    end
  
    ## Display a chooser page
    def render_page(view, locals={})
    
      ## HAML rendering options
      Haml::Template.options[:format] = :html5
    
      ## Render and return the page
      haml = Haml::Engine.new(views[view])
      return haml.render(Object.new, locals)
    
    end
  
    ## Add attribute information to the headers passed to application
    def inject_attribute_headers(env, user_details)
    
      ## Convert to proper format that matches the live SP (also add new ones)
      prepared_data = process_attribute_data(user_details)
    
      ## Now the useful bit
      prepared_data.each_pair do | header, value| 
      
        env[header] = value
      
      end
    
    end

    ## Add attribute information to the headers passed to application
    def inject_session_headers(env, user_details)
    
      ## Application ID
      env['Shib-Application-ID'] = 'default'
    
      ## Persistent Session ID
      session_id = env['rack.session']['shibkit-sp_simulator'][:sessionid]
      env['Shib-Session-ID'] = session_id
    
      ## Identity Provider ID
      env['Shib-Identity-Provider'] = 'https://shib.example.ac.uk/shibboleth'
    
      ## Time authentication occured
      env['Shib-Authentication-Instant'] = env['rack.session']['shibkit-sp_simulator'][:logintime]
    
      ## Keep login method rather vague
      env['Shib-Authentication-Method'] = 'urn:oasis:names:tc:SAML:1.0:am:unspecified'
      env['Shib-AuthnContext-Class']    = 'urn:oasis:names:tc:SAML:1.0:am:unspecified'
    
      ## Assertion headers are cargo-culted for not (not sensible - Do Not Use)
      assertion_header_info(session_id, user_details).each_pair {|header, value| env[header] = value}
      env['Shib-Assertion-Count'] = "%02d" % assertion_header_info(session_id, user_details).size
    
      ## Is targeted ID set to be automatic?
      # ...
    
    end
  
    ## Munge the data in attributes to match Shib/SAML expectations
    def process_attribute_data(user_details)
    
      munged_data = user_details.dup
    
      ## Call out to filter (this is monkey patched by shibsim_filter.rb)
      munged_data = user_record_filter(munged_data)
          
      return munged_data
    
    end
    
    ## User-overridable method - monkey patch with shibsim_filter.rb
    def user_record_filter(munged_data)
      
      return munged_data
      
    end
    
  
    ## Create information for mocking assertion headers
    def assertion_header_info(session_id, user_details) 
    
      info = Hash.new
      
      ## We need this again in order to calculate accurate assertion size
      munged_data = process_attribute_data(user_details)
      
      ## This should be based on total size of assertion data I believe (this is Shib1.3 style?)
      (1..2).each do |assertion_part|
      
        ## Each assertion fragment gets a numbered identifier
        header = 'Shib-Assertion-' + "%02d" % assertion_part
      
        ## Building up a mock URL
        value  = @config['default_session']['assbase'] + '?key=' + session_id + '&ID=' + xsid_generator
    
        ## Collect it
        info[header] = value
      
      end
    
      return info
  
    end
  
    ## 
    def set_session(env, user_details)
      
      puts user_details.inspect
      
      ## Create rack based session for our data (existence indicates shibsim session is active)
      env['rack.session']['shibkit-sp_simulator'] ||= Hash.new
      
      ## Keep the user ID so we can reapply attributes in the future
      env['rack.session']['shibkit-sp_simulator'][:userid] ||= user_details['id']
      
      ## Contruct a session ID is if we don't have one
      env['rack.session']['shibkit-sp_simulator'][:sessionid] ||= xsid_generator
    
      ## Store login time as a string in xs:DateTime format (with no timezone for some reason)
      env['rack.session']['shibkit-sp_simulator'][:logintime] ||= Time.new.xmlschema.gsub(/(\+.*)/, 'Z')
    
      ## Inject data into the headers that application will receive
      inject_attribute_headers(env, user_details)
    
      ## Fake various Shibboleth headers that are session-specific
      inject_session_headers(env, user_details)
  
    
    end

    ## Remove ShibSimulator params, etc from request before it reaches application
    def tidy_request(env)
    
      req = Rack::Request.new(env)
    
      [:shibsim_user, :shibsim_reset].each do |param|
    
        req.params.delete(param.to_s)
    
      end
    
    end
  
    ## List user records by ID
    def users
    
      return user_data[0]
  
    end
  
    ## List user records by ID
    def organisations
  
      return user_data[1]
  
    end

    ## Load and prepare HAML views
    def views
    
      unless @views
    
        @views = Hash.new
    
        VIEWS.each do |view| 

          view_file_location = "#{::File.dirname(__FILE__)}/shib_sim/views/#{view.to_s}.haml"
          @views[view] = IO.read(view_file_location)

        end
    
      end
    
      return @views
    
    end
  
    ## Provide user data for chooser and header injection
    def user_data
    
      unless @users && @orgtree
    
        @users   = Hash.new
        @orgtree = Hash.new 
      
        user_fixture_file_location = "#{::File.dirname(__FILE__)}/shib_sim/default_data/users.yml"

        fixture_data = YAML.load_file(user_fixture_file_location)

        fixture_data.each_pair do |label, record| 
 
          record['shibsim_label'] = label.to_s.strip
          rid  = record['id'].to_s
          rorg = record['organisation'].to_s.strip

          @users[rid]    =   record        
          @orgtree[rorg] ||= Array.new
        
          @orgtree[rorg] <<  record 
        
        end
 
      end

      return [@users, @orgtree]
    
    end
  
    ## Unique identifiers for user Shibboleth SP session, etcs
    def xsid_generator
    
      ## Reset seed of random sequence using current time
      srand
    
      ## Like an MD5sum of nothing in particular
      return '_' + rand(0xffffffffffffffffffffffffffffffff).to_s(16)
    
    end
    
    ## Load and cache the user config file specified when middleware loaded
    def load_config_file(specified_file)
      
      ## If file was specified when the middleware was loaded, use that.
      file_location = specified_file if specified_file
      
      ## Otherwise try the config-by-convention location if file exists
      file_location ||= APP_CONFIG if ::File.exists? APP_CONFIG
      
      ## If nothing set so far, fall back to the built-in default
      file_location ||= DEFAULT_CONFIG
      
      ## Load and parse the YAML config file
      @config = YAML.load_file(file_location)
      
    end
    
    ## Add the filter mixin if it exists
    def load_filter_mixin
      
      ## Try the config-by-convention location if file exists
      file_location ||= APP_FILTER if ::File.exists? APP_FILTER
      
      ## If nothing set so far, fall back to the built-in default
      file_location ||= DEFAULT_FILTER
      
      ## Mixin the filter Mixin
      require file_location
      extend Rack::ShibSim::RecordFilter
      
    end
    
    def check_state
      
      raise "No user data!" unless @users.size > 0 
      raise "No organisation labels!" unless @orgtree.size > 0
      
    end
    
  end

end

