class ShibSimulator
  
  require 'haml'
  require 'haml/template'
  require 'yaml'
  
 
 
  ##
  ## Setup views, default data, etc
  ##

  
  ## Load default data
  DEFAULT_MAPPER = {}
  #DEFAULT_DATA = prepare_user_data()
  CONTENT_TYPE   = { "Content-Type" => "text/html; charset=utf-8" }
  VIEWS          = [:user_chooser, :fatal_error]

  ## Initial vars for storing cached data
  @@views    = nil
  @@users    = nil
  @@orgtree  = nil 
  
  ## Default configuration
  @@config = {
    :org_from          => :attribute,
    :org_attr          => 'organisation',
    :org_mapper_config => :default  
  }
  
  def initialize(app, data_source=DEFAULT_DATA, data_mapper=DEFAULT_MAPPER)
    
    @app = app
    @data_source = data_source
    @data_mapper = data_mapper
    
    ## Get access to a hash of hashes that store the data (fixture style)
    # ... Check and tidy the hash
    
    ## Hash to change keys to match Shibboleth headers in use
    # ...

  end
  
  ## Selecting an action and returning to the Rack stack 
  def call(env)
    
    ## Peek at user input, they might be talking to us
    req = Rack::Request.new(env)
    
    begin
      
      ## Reset session?
      reset_session(env) if req.params['shibsim_reset']
  
      ## Already set? Then re-inject the headers (they are outside session)
      if env["rack.session"]['shib_simulator_active']
        
        ## Add appropriate headers
        inject_headers(env)#, user_details)
        
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
          
          ## Update session
          set_session(env, user_id)
          
          ## Add headers to request
          inject_headers(env, user_details)
          
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
 
    env["rack.session"]['shib_simulator_active'] = false
    
    tidy_request(env)
    
  end

  ## Error page for unrecoverable situations
  def fatal_error_action(env, oops)
    
    puts "Shibkit Rack error: " + oops.to_s
    puts "Backtrace is:\n#{oops.backtrace.to_yaml}"
    
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
  
  ## Add information to the headers passed to application
  def inject_headers(env, user_details)
    
    
    
  end
  
  ## Convert user data into Shibboleth SP style header values
  def map_attributes_to_headers
    
    
    
  end
  
  ## 
  def set_session(env, user_id)
    
    ## Convert to proper format that matches the live SP                                                                                                                                         
    # ...
    
    ## Inject data into the headers that application will receive
    # ...
    
    ## Fake various Shibboleth headers that are session-specific
    # ...
    
    ## Mark in session (shared with Rails) that bodge has been applied
    env["rack.session"]['shib_simulator_active'] = true
    
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
    
    unless @@views
    
      @@views = Hash.new
    
      VIEWS.each do |view| 

        view_file_location = "#{File.dirname(__FILE__)}/rack_views/#{view.to_s}.haml"
        @@views[view] = IO.read(view_file_location)

      end
    
    end
    
    return @@views
    
  end
  
  ## Provide user data for chooser and header injection
  def user_data
    
    unless @@users && @@orgtree
    
      @@users   = Hash.new
      @@orgtree = Hash.new 
      
      user_fixture_file_location = "#{File.dirname(__FILE__)}/default_data/user_data.yml"

      fixture_data = YAML.load_file(user_fixture_file_location)

      fixture_data.each_pair do |label, record| 
 
        record['shibsim_label'] = label.to_s.strip
        rid  = record['id'].to_s
        rorg = record['organisation'].to_s.strip

        @@users[rid]    =   record        
        @@orgtree[rorg] ||= Array.new
        
        @@orgtree[rorg] <<  record 
        
      end
 
    end
    
    
    puts @@users.inspect
    puts @@orgtree.inspect
    
    return [@@users, @@orgtree]
    
  end
  

  
end

