
module ShibUser
  
  ## Mixin to interface to env data via Rack using default and IDP-specific maps
  module UsesSPEnvForAttrs
    
    private
    
    ## Load the attr map hash from either default or user-specified map file
    def load_attr_hash(map_name, other_file=nil)
      
      ## Grumble if the file is specified but can't be found # TODO
      # ...
      
      ## This is the key in the hash tree for the map we want, needs to be string
      map_name = map.to_s
      
      ## Load the map SP->Attribute map # TODO: Allow option to override this
      default_file = "#{::File.dirname(__FILE__)}/shib_shim/default_config/sp_attr_map.yml"
      
      ## Load the default file first
      attr_map = YAML.load_file(default_file)[map_name]
    
      ## Now load the application map if it exists, and overlay it
      if other_file and File.exists?(file) then
        
        app_attr_map = YAML.load_file(file)[map_name]
        
        attr_map.merge!(app_attr_map)
        
      end
    
      return map
    
    end
    
    ## Extract data for attribute from SP data in Rack environment vars
    def data_from_sp(attribute, rack_env)
      
      return rack_env(header_for(attribute, rack_env))
      
    end
    
    ## Use the correct map
    def header_for(attribute)
      
      attribute = attribute.to_s
      
      map = DEFAULT_SP_ATTR_MAP_DATA
      
      ## Check for IDP-specific attribute map
      
      header = map
      
      
    end
    
  end
  
  class Assertion
    
    attr_reader :login_time
    attr_reader :remote_user
    attr_reader :session_id
    attr_reader :application
    attr_reader :auth_instant
    attr_reader :auth_method
    attr_reader :auth_class
    attr_reader :ip_address
    attr_reader :proxied
    attr_reader :forwarded_for
    attr_reader :proxies
    attr_reader :idp_uri
    attr_reader :attrs
    attr_reader :xattrs
    
    def initialize(rack_env, options={}) 
      
      ## IDP object for this assertion. Get this directly, used to get others
      @idp_uri         = rack_env('Shib-Identity-Provider').to_s.downcase
      
      ## Check we have a valid URI for the IDP - can't continue without this
      # ...      
            
      ## The moment this object is created
      @login_time     = Time.new
      
      ## The Web server's remote user env variable - not always set! Avoid!
      @remote_user    = rack_env('REMOTE_USER') || nil
      
      ## Shibboleth IDP/SP session
      @session_id     = rack_env('Shib-Session-ID')
      
      ## The SPs application context
      @application    = rack_env('Shib-Application-ID') || 'default'
      
      ## Time the user authenticated at the IDP, stored as string
      @auth_instant   = rack_env('Shib-Authentication-Instant')
      
      ## Method the user used to authenticate, cropped to last (significant) element
      @auth_method    = rack_env('Shib-Authentication-Method')
      
      ## Authentication class, cropped to last (significant) element
      @auth_class     = rack_env('Shib-AuthnContext-Class')
      
      ## *Initial* IP address at login - we can check for changes using this
      @ip_address     = rack_env('REMOTE_ADDR')
      
      ## Does the address look proxied?
      @proxied =  rack_env('X-Forwarded-For') ? true : false
      
      ## Forwarded for IP address, if proxied.
      @forwarded_for = rack_env('X-Forwarded-For').split(',')[0]
      
      ## Proxies declared by the forwarded_for header (limited to 5)
      @proxies       = rack_env('X-Forwarded-For').split(',')[1..5]
    
      ## User profile from the IDP; derived from standard eduPerson and simplified
      @attrs     = ShibUser::BasicAttrs.new(rack_env)
      
      ## Custom user profile from the IDP etc. Can't be relied up between apps
      @xattrs = ShibUser::CustomAttrs.new(rack_env)
      
      ## Check everything is valid; if not, we complain
      # ...
      
      
    end
    
    private
    
  end
  
  ## Attributes asserted directl by the IDP, trustable and standardised
  class BasicAttrs
    
    extend UsesSPEnvForAttrs
    
    attr_reader :targeted_id
    attr_reader :org_username
    attr_reader :dn
    attr_reader :eppn
    attr_reader :display_name
    attr_reader :given_name
    attr_reader :family_name
    attr_reader :organisation
    attr_reader :org_units
    attr_reader :entitlements
    attr_reader :scoped_affiliations
    attr_reader :affiliations
    attr_reader :mail
    attr_reader :personal_title
    attr_reader :org_title
    attr_reader :url
    attr_reader :phone
    attr_reader :address
    attr_reader :postcode
    attr_reader :description
    attr_reader :photo_data
    attr_reader :photo_url    
    attr_reader :language
    attr_reader :certificate
    
    ## Load the map SP->Attribute map # TODO: Allow option to override this
    @@map ||= load_attr_hash('basic_attributes')
    
    def initialize(rack_env, options={})
      
      
      
      
      
      ## Unique ID for this idp + user + service
      @targeted_id = data_from_sp('targeted_id', rack_env))
      
      ## Username at the organisation (not likely to be provided unless local integration required)
      @org_username = data_from_sp(attribute, rack_env)'uid') || rack_env('cn') || nil
      
      ## LDAP DN of user at local organisation (not likely to be needed)
      @dn = data_from_sp(attribute, rack_env)'dn')
      
      ## EduPersonPrincipalName - scoped federation-wide identifier using a local identifier
      @eppn = data_from_sp(attribute, rack_env)'eppn')
      
      ## Personal name 
      @given_name = data_from_sp(attribute, rack_env)'givenName')
      
      ## Surname
      @family_name = data_from_sp(attribute, rack_env)'')
      
      ## Preferred display name for user
      @display_name = data_from_sp(attribute, rack_env)'display_name') 
      
      ## Name of organisation as provided by IDP
      @organisation = data_from_sp(attribute, rack_env)
      
      ## Org units (ou)
      @org_units = data_from_sp(attribute, rack_env)
      
      ## Entitlement uris
      @entitlements = data_from_sp(attribute, rack_env)
      
      ## Affiliations
      @affiliations = data_from_sp(attribute, rack_env)
      
      ## Affilations with scope, either explicit or calculated
      @scoped_affiliations = data_from_sp(attribute, rack_env)
      
      ## Email address
      @mail = data_from_sp(attribute, rack_env)
      
      ## Personal title (Mr, Mrs, Ms, etc)
      @personal_title = data_from_sp(attribute, rack_env)
      
      ## Official title at the organisation
      @org_title = data_from_sp(attribute, rack_env)
      
      ## URL of the user´(homepage, profile, etc)
      @url = data_from_sp(attribute, rack_env)
      
      ## Official telephone number
      @phone = data_from_sp(attribute, rack_env)
      
      ## Mobile phone (org or personal)
      @mobile = data_from_sp(attribute, rack_env)
      
      ## Organisation postal address
      @address = data_from_sp(attribute, rack_env)
      
      ## Postcode of user (for geolocation)
      @postcode = data_from_sp(attribute, rack_env)
      
      ## Description text for user
      @description = data_from_sp(attribute, rack_env)
      
      ## Embedded photo for user # TODO: Need to check possible size problems here
      @photo_data = data_from_sp(attribute, rack_env)
      
      ## Photo URI (could be local (ref to data) or Internet)
      @photo_url  = data_from_sp(attribute, rack_env)
      
      ## Prefered Language (Defaults to en)
      @language = data_from_sp(attribute, rack_env)      
      
    end

    
  end
  
  ## Attributes specific to this application, derived from IDP or from elsewhere
  class CustomAttrs
    
    extend UsesSPEnvForAttrs
    
    ## Load the map SP->Attribute map # TODO: Allow option to override this
    @@map ||= load_attr_hash('custom_attributes')
    
    
  end
  

  
end