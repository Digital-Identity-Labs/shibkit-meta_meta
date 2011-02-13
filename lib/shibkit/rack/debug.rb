class Shibkit::Rack::Debug  < Shibkit::Rack::Base


  def initialize(app)
    
    #@app = app
    
    ## Cache a couple of options (config should be frozen anyway)
    #@user_id_name   = config.shim_user_id_name
    #@assertion_name = config.shim_sp_assertion_name
    
  end
  
  ## Middleware entry point: Extract info from SP headers, encapsulate in user object, continue
  def call(env)
    
    ## Extract information from SP headers and pass to user assertion object
    #sp_assertion_data = process_sp_session(env)
    #shib_session = Shibkit::SPAssertion.new(sp_assertion_data)
    
    ## Check that user is consistent with SP status, to cope with changes:
    #
    
    ## Store in session # TODO: Make this configurable
    #env['rack.session'][@assertion_name] = shib_session  
    
    return @app.call(env)
    
  end

  private
  
end