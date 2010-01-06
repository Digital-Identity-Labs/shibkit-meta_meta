class ShibSimulator
  
  require 'haml'
  require 'haml/template'
  
 
 
  ##
  ## Setup views, default data, etc
  ##

  
  ## Load default data
  DEFAULT_MAPPER = {}
  #DEFAULT_DATA = prepare_user_data()

   @@views = nil
 
  def initialize(app, data_source=DEFAULT_DATA, data_mapper=DEFAULT_MAPPER)
    
    @app = app
    @data_source = data_source
    @data_mapper = data_mapper
    
    ## Get access to a hash of hashes that store the data (fixture style)
    # ... Check and tidy the hash
    
    ## Hash to change keys to match Shibboleth headers in use
    # ...

  end

  def call(env)
    
    ## Peek at user input, they might be talking to us
    req = Rack::Request.new(env)
    
    ## Reset session?
    reset_session(env) if req.params['shibsim_reset']
  
    ## Already set? Then our work here is done.
    return @app.call(env) if env["rack.session"]['shib_simulator_active']

    ## Directly requested user or user? (via URL param)
    user_id = req.params['shibsim_user']

    ## Bodge session or display a page showing the list of available fixtures
    if user_id 
      
      set_session(env, user_id)
      tidy_request(env)

      return @app.call(env)
          
    else
 
      page_body = render_page(:user_chooser)

      status, headers, body = @app.call env
      
      tidy_request(env)
        
      return 200, { "Content-Type" => "text/html; charset=utf-8" }, [page_body.to_s] 
      
    end

  end
  
  ## Wipe clean the Rack session info for this middleware
  def reset_session(env)
 
    env["rack.session"]['shib_simulator_active'] = false
    
    tidy_request(env)
    
  end
  
  ## Display a chooser page
  def render_page(view, options={})
    
    ## HAML rendering options
    Haml::Template.options[:format] = :html5
    
    ## Render and return the page
    haml = Haml::Engine.new(views[view])
    return haml.render
    
  end
  
  ## 
  def set_session(env, user_id)
  
    ## Get our user information
    # ...
    
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
  
  private
  
  ## Load and prepare HAML views
  def views
    
    unless @@views
    
      @@views = Hash.new
    
      [:user_chooser].each do |view| 

        view_file_location = "#{File.dirname(__FILE__)}/rack_views/#{view.to_s}.haml"
        @@views[view] = IO.read(view_file_location)

      end
    
    end
    
    return @@views
    
  end
  
  ## Load and prepare user fixture data or default data 
  def prepare_user_data
    
    
    
    
  end
  
end

