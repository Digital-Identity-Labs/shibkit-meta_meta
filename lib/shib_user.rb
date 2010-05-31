
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
    
    ## Returns the asserted persistent-id value or upgrades from botched/targeted-id
    def persistent_id
      
      ## If we have an literal persistent_id attribute then return that
      return attrs.persistent_id unless attrs.persistent_id.empty?
      
      ## TODO: Need to check that the format is correct - effectively normalise?
      # ...
      
      ## Reformat the older 'botched' format if we have it...
      unless attrs.targeted_id.empty?
     
        ## Use the user ID
        user_id, user_scope = attrs.targeted_id.split('@')
        
        ## The SP's ID # TODO: This is hardcoded! BAD! *Must* get from config!
        sp_id = 'https://sp.example.ac.uk/shibboleth'  
     
        return [idp_uri, sp_id, user_id].join('!')
     
      end
      
      ## Check the format of remote user, log a grumble, then use it
      # ...
      
      ## Nothing we can use! # TODO: need to catch this with a special halt, since caused by unconfigured SP
      raise "No persistent ID is present!"
      
      ## TODO: this method just isn't production quality yet.
      
    end
    
    private
    
  end
  
  ## Attributes asserted directly by the IDP, trustable and standardised
  class BasicAttrs
    
     PACCS = [
      :targeted_id,
      :persistent_id,
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