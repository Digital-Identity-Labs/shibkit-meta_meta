
module ShibUser
  
  ## General session information, container for attribute sets, basic user information
  class Assertion
    
    PACCS = [
      :login_time,
      :remote_user,
      :session_id,
      :application,
      :auth_instant,
      :auth_method,
      :auth_class,
      :ip_address,
      :proxied,
      :forwarded_for,
      :proxies,
      :idp_uri,
      :attrs,
      :xattrs
    ].freeze
    
    ## Create read-only accessor methods
    PACCS.each { |attrib| attr_reader attrib }
    
    def initialize(data={}, options={}) 
      
      ## Directly set instance variables with data hash # TODO: optimise?
      PACCS.each { |pacc| eval("@#{pacc} = data[pacc]") }
        
      ## Upgrade SP attrs from hashes to objects
      @attrs  = ShibUser::BasicAttrs.new(@attrs)
      @xattrs = ShibUser::CustomAttrs.new(@xattrs)
      
      ## Check everything is valid; if not, we complain
      # ...
          
    end
    
    private
    
  end
  
  ## Attributes asserted directly by the IDP, trustable and standardised
  class BasicAttrs
    
     PACCS = [
      :targeted_id,
      :org_username,
      :dn,
      :eppn,
      :display_name,
      :given_name,
      :family_name,
      :organisation,
      :org_units,
      :entitlements,
      :scoped_affiliations,
      :affiliations,
      :mail,
      :personal_title,
      :org_title,
      :url,
      :phone,
      :address,
      :postcode,
      :description,
      :photo_data,
      :photo_url,  
      :language,
      :certificate
    ].freeze
    
    ## Create read-only accessor methods
    PACCS.each { |attrib| attr_reader attrib }
    

    def initialize(data = {}, options={})
        
      ## Directly set instance variables with data hash # TODO: optimise?
      PACCS.each { |pacc| eval("@#{pacc} = data[pacc]") }
 
    end

    
  end
  
  ## Attributes specific to this application, derived from IDP or from elsewhere
  class CustomAttrs
    
    PACCS = []
    
    ## Create accessor methods from the map
    # ...
    
    def initialize(data = {}, options={})
    
      ## Directly set instance variables with data hash # TODO: optimise?
      PACCS.each { |pacc| eval("@#{pacc} = data[pacc]") }
    
    end
    
  end
  

  
end