class Rack::ShibShim

  require 'deep_merge'

  require 'shib_user'

  def initialize(app)
    
    @app = app
    
  end
  
  ## Middleware entry point: Extract info from SP headers, encapsulate in user object, continue
  def call(env)
    
    ## Extract information from SP headers and pass to user assertion object
    sp_assertion = process_sp_session(env)
    shib_user = ShibUser::Assertion.new(sp_assertion)
      
    ## Store in session
    env['rack.session'][:shib_user] = shib_user  
    
    return @app.call(env)
    
  end

  private
  
  ## Extract init data for user object 
  def process_sp_session(rack_env) 
    
    sp_sess = Hash.new
    sp_sess.default = ""
    
    ## IDP object for this assertion. Get this directly, used to get others
    sp_sess[:idp_uri]         = rack_env['Shib-Identity-Provider'].to_s.downcase
    
    ## Check we have a valid URI for the IDP - can't continue without this
    # ...      
          
    ## The moment this object is created
    sp_sess[:login_time]     = Time.new
    
    ## The Web server's remote user env variable - not always set! Avoid!
    sp_sess[:remote_user]    = rack_env['REMOTE_USER'] || nil
    
    ## Shibboleth IDP/SP session
    sp_sess[:session_id]     = rack_env['Shib-Session-ID']
    
    ## The SPs application context
    sp_sess[:application]    = rack_env['Shib-Application-ID'] || 'default'
    
    ## Time the user authenticated at the IDP, stored as string
    sp_sess[:auth_instant]   = rack_env['Shib-Authentication-Instant']
    
    ## Method the user used to authenticate, cropped to last (significant) element
    sp_sess[:auth_method]    = rack_env['Shib-Authentication-Method']
    
    ## Authentication class, cropped to last (significant) element
    sp_sess[:auth_class]     = rack_env['Shib-AuthnContext-Class']
    
    ## *Initial* IP address at login - we can check for changes using this
    sp_sess[:ip_address]     = rack_env['REMOTE_ADDR']
    
    ## Does the address look proxied?
    sp_sess[:proxied] =  rack_env['X-Forwarded-For'] ? true : false
    
    ## Forwarded for IP address, if proxied.
    sp_sess[:forwarded_for] = @proxied ? rack_env['X-Forwarded-For'].split(',')[0] : nil 
    
    ## Proxies declared by the forwarded_for header (limited to 5)
    sp_sess[:proxies]       = rack_env['X-Forwarded-For'].split(',')[1..5] if @proxied
  
    ## User profile from the IDP; derived from standard eduPerson and simplified
    sp_sess[:attrs] = process_core_attributes(rack_env)
    
    ## Custom user profile from the IDP etc. Can't be relied up between apps
    sp_sess[:xattrs] = process_ext_attributes(rack_env)
    
    return sp_sess
    
  end
  
  ## Extract attribute data from environment
  def process_core_attributes(rack_env)
 
    sp_core = Hash.new
    sp_core.default = nil
    
    ## Object that wraps up access to the headers, per-IDP, with defaults, etc. 
    sp_headers = Rack::ShibShim::SPAttributeHeaders.new('core_attribute_maps', rack_env)
    
    ## Extract each header
    [    
      :targeted_id, ## Unique ID for this idp + user + service
      :org_username, ## Username at the organisation (not likely to be provided unless local integration required)
      :dn,## LDAP DN of user at local organisation (not likely to be needed)
      :eppn,  ## EduPersonPrincipalName - scoped federation-wide identifier using a local identifier
      :given_name, ## Personal name 
      :family_name,  ## Surname
      :display_name, ## Preferred display name for user
      :organisation, ## Name of organisation as provided by IDP
      :org_units, ## Org units (ou)
      :entitlements, ## Entitlement uris
      :affiliations, ## Affiliations
      :scoped_affiliations, ## Affilations with scope, either explicit or calculated
      :mail, ## Email address
      :personal_title, ## Personal title (Mr, Mrs, Ms, etc)
      :org_title, ## Official title at the organisation
      :url, ## URL of the user´(homepage, profile, etc)
      :phone, ## Official telephone number
      :mobile, ## Mobile phone (org or personal)
      :address, ## Organisation postal address
      :postcode, ## Postcode of user (for geolocation)
      :description, ## Description text for user
      :photo_data, ## Embedded photo for user # TODO: Need to check possible size problems here
      :photo_url, ## Photo URI (could be local (ref to data) or Internet)
      :language ## Prefered Language (Defaults to en)     
    ].each { |attrib| sp_core[attrib] = sp_headers.get(attrib) }
    
    return sp_core
    
  end
  
  ## Extra attribute data from environment
  def process_ext_attributes(rack_env)
    
    sp_ext = Hash.new
    sp_ext.default = nil
    
    ## Object that wraps up access to the headers, per-IDP, with defaults, etc. 
    sp_headers = Rack::ShibShim::SPAttributeHeaders.new('custom_attribute_maps', rack_env)
    
    ## We get our headers from the defaults keys
    sp_headers.attributes.each { |attrib| sp_ext[attrib] = sp_headers.get(attrib) }
    
    return sp_ext
    
  end
  
  
  ## Utility class to make extraction of SP headers a bit cleaner
  class SPAttributeHeaders
    
    attr_reader :maps
    attr_reader :map_category
    attr_reader :idp
    
    ## Store map name and rack env so we don't need to specify them for every attribute
    def initialize(map_cat, rack_env)
    
      @map_category  = map_cat.to_s
      @rack_env = rack_env
      
      ## We choose the attribute map by IDP id, so we need to extract it
      @idp = rack_env['Shib-Identity-Provider'].to_s.strip.downcase
      
      ## Store ref to the relevant set of maps
      @maps = @@attr_maps[@map_category]
      
    end
    
    ## Grab the data from appropriate header
    def get(attribute)
    
      ## Normalise a few things
      attribute = attribute.to_s
      
      ## What header to use for this attribute? Start with the default one
      sp_header = find_sp_header_for_idp(attribute) 
        
      ## Actually look up the header
      data = @rack_env[sp_header]

      return data
    
    end
    
    ## List default set of attributes for a map (keys in config file)
    def attributes
      
      attributes = maps['default'].keys.sort
      
      return attributes
      
    end
    
    private
    
    ## Find the correct header for the attribute for this IDP 
    def find_sp_header_for_idp(attribute)
    
      header = 'default'
      attribute = attribute.to_s
      
      puts "#{attribute} for #{idp}"
      
      ## Change to use the IDP one if it exists
      if maps[idp] and maps[idp][attribute] then
         
        ## Use the IDP-specific header 
        header = maps[idp][attribute]
         
      else
         
        ## Use the default header if it exists
        header = maps['default'][attribute] if maps['default'] and
          maps['default'][attribute]
         
      end
   
      puts "  ... Found #{header}"
   
      return header
      
    end
    
    ## Load and merge the attr maps hash from default and app map files
    def SPAttributeHeaders::load_maps(other_file=nil)

      ## Grumble if the file is specified but can't be found # TODO
      # ...

      ## Load the map SP->Attribute map # TODO: Allow option to override this
      default_file = "#{::File.dirname(__FILE__)}/shib_shim/default_config/sp_attr_map.yml"

      ## Load the default file first into default attribute maps store
      @@default_attr_maps = YAML.load_file(default_file)

      ## By default, we start with the default. Seems reasonable.
      @@attr_maps         = @@default_attr_maps
      @@attr_maps.default = Hash.new
      @@app_attr_maps     = Hash.new

      ## Now load the application map if it exists, and overlay it
      if other_file and ::File.exists?(other_file) then
        
        ## Load the application attribute map
        @@app_attr_maps = YAML.load_file(other_file)
        
        ## Merge the application's attribute map on top of default map
        @@attr_maps = @@default_attr_maps.deep_merge(@@app_attr_maps)
       
      end
      
    end
    
    ## Cache the default and application map hashes in the class
    SPAttributeHeaders::load_maps(other_file=nil) # TODO: need way to set/get/find app map file too.
    
  end
  
end
