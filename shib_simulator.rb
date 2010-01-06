class ShibSimulator
  
  require 'haml'
  require 'haml/template'
  
  DEFAULT_DATA = {
    "Pete Birkinshaw at University of Manchester" => {
      #Shib-Application-ID = default
      #Shib-Session-ID = _41c1a44129c6dac0e570dc2ccc2a3b8e
      #Shib-Identity-Provider = https://shib.manchester.ac.uk/shibboleth
      #Shib-Authentication-Instant = 2009-12-29T20:22:16.195Z
      #Shib-Authentication-Method = urn:oasis:names:tc:SAML:1.0:am:unspecified
      #Shib-AuthnContext-Class = urn:oasis:names:tc:SAML:1.0:am:unspecified
      #Shib-Assertion-01 = http://localhost/Shibboleth.sso/GetAssertion?key=_41c1a44129c6dac0e570dc2ccc2a3b8e&ID=_8c76f4d665f14df97422603f5457859b
      #Shib-Assertion-02 = http://localhost/Shibboleth.sso/GetAssertion?key=_41c1a44129c6dac0e570dc2ccc2a3b8e&ID=_3ea034792a6fc93c158eaef138b5a30f
      #Shib-Assertion-Count = 02
      #affiliation = staff@manchester.ac.uk;member@manchester.ac.uk;alum@manchester.ac.uk
      #displayName = Pete Birkinshaw
      #entitlement = urn:mace:oclc.org:100324218;urn:mace:dir:entitlement:common-lib-terms;http://directory.manchester.ac.uk/epe/portal/role/I2005/I3049/staff;http://directory.manchester.ac.uk/epe/pkm/ra/analyst;http://directory.manchester.ac.uk/epe/man#jorumforstaff;http://directory.manchester.ac.uk/epe/man#default0;http://directory.manchester.ac.uk/epe/devtest/default;man#jorumforstaff;man#default0
      #eppn = 50152327@manchester.ac.uk
      #givenName = Pete
      #mail = Peter.Birkinshaw@manchester.ac.uk
      #ou = Infrastructure and Operations;IT Services;Administration & Central Services
      #personalTitle = Mr
      #sn = Birkinshaw
      #targeted-id = oAXK0FHBjGeHud5KkNJDD+stcns=@manchester.ac.uk
      #title = Senior IT Officer, Registration Services
      #unscoped-affiliation = staff;member;alum
      'unscoped-affiliation' => 'staff;member;alum'
      }
  }
 
  DEFAULT_MAPPER = {}
 
CHOOSER_HAML = <<HAML
!!!
%html{ :xmlns => "http://www.w3.org/1999/xhtml", :lang => "en", "xml:lang" => "en"}
  %head
    %title Shibboleth Simulator: Login
    %meta{"http-equiv" => "Content-Type", :content => "text/html; charset=utf-8"}
  %body
    #header
      %h1 Login
      %h2 Please Choose A User
    #content
      %p
        %a{:href => "/?shibsim_user=1"} Pete Birkinshaw at University of Manchester
    #footer
      %p
        All content copyright © Pete  

HAML
 
  def initialize(app, data_source=DEFAULT_DATA, data_mapper=DEFAULT_MAPPER)
    
    @app = app
    @data_source = data_source
    @data_mapper = data_mapper
    
    ## Get access to a hash of hashes that store the data (fixture style)
    # ... Check and tidy the hash
    
    ## Hash to change keys to match Shibboleth headers in use
    # ...
    
    puts '1'
    
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
    
        puts '2'

    ## Bodge session or display a page showing the list of available fixtures
    if user_id 
      
      set_session(env, user_id)
      
               puts '3'
      
      return @app.call(env)
      
 
      
    else
 
      page_body = generate_chooser_page(env)

    puts '4'
    puts page_body
    status, headers, body = @app.call env
    puts status.inspect
    puts headers.inspect
    puts page_body.inspect
    
    puts req.query_string
    
    #return [status, headers, page_body]
    return 200, { "Content-Type" => "text/html; charset=utf-8" }, [page_body.to_s] 
      
    end

  end
  
  ## Wipe clean the Rack session info for this middleware
  def reset_session(env)
    
             puts '5'
    
    env["rack.session"]['shib_simulator_active'] = false
    
  end
  
  ## Display a chooser page
  def generate_chooser_page(env)
    
    ## HAML rendering options
    Haml::Template.options[:format] = :html5
    
    ## Render and return the page
    haml = Haml::Engine.new(CHOOSER_HAML)
    return haml.render
    
  end
  
  ## 
  def set_session(env, user_id)
  
           puts '7'
  
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

end

