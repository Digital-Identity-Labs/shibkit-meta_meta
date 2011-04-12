require 'shibkit/rack/simulator/models/entity_service'

module Shibkit
  module Rack
    class Simulator
      module Model
        class IDPService < EntityService
          
          require 'shibkit/rack/base/mixins/http_utils'
          
          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
          
          include Shibkit::Rack::Base::Mixin::HTTPUtils
          
          setup_storage
          
          attr_accessor :scopes
          attr_accessor :scope
          attr_accessor :auth_attribute
          attr_accessor :pid_attribute
          attr_accessor :auth_method
          attr_accessor :auth_class
          attr_accessor :add_tid
          attr_accessor :directory
          attr_accessor :sso            
          attr_accessor :auth_attribute 
          attr_accessor :pid_attribute  
          attr_accessor :auth_method_uri
          attr_accessor :auth_class_uri 
          attr_accessor :idp_type       
          attr_accessor :add_tid        
          attr_accessor :session_expiry 
          attr_accessor :idp_base_path
          attr_accessor :login_path
          attr_accessor :logout_path
          attr_accessor :new_status_path
          attr_accessor :old_status_path
          attr_accessor :authn_path       

          ## Copy data from a suitable MetaMeta object
          def from_metadata(entity)
          
            @display_name  = entity.organisation.display_name
            @uri           = entity.entity_uri
            @metadata_id   = entity.metadata_id
            @url           = entity.organisation.url
            @scopes        = entity.scopes
            @scope         = entity.scopes[0]
            
          end
          
          ## Set properties from a list of defaults
          def from_defaults(default_list, entity_id=uri)
            
            defaults = default_list[entity_id] || default_list["default"]
            
            @sso             = defaults['sso']             || true
            @auth_attribute  = defaults['auth_attribute']  || 'uid'
            @pid_attribute   = defaults['pid_attribute']   || 'uid'
            @auth_method_uri = defaults['auth_method_uri'] || 'urn:oasis:names:tc:SAML:1.0:am:unspecified'
            @auth_class_uri  = defaults['auth_class_uri']  || 'urn:oasis:names:tc:SAML:1.0:am:unspecified'
            @idp_type        = defaults['idp_type']        || 'shibboleth2'
            @add_tid         = defaults['add_tid']         ||  true
            @session_expiry  = defaults['session_expiry']  ||  300
            @idp_base_path   = defaults['idp_base_path']        ||  "/idp/"
            @old_status_path = defaults['old_status_path'] ||  "/profile/Status"
            @new_status_path = defaults['new_status_path'] ||  "/status"
            @authn_path      = defaults['authn_path']      ||  "/profile/Shibboleth/SSO"
            @login_path      = defaults['login_path']      ||  "/login"
            @logout_path     = defaults['logout_path']     ||  "/logout"
            @authn_path      = defaults['authn_path']      ||  "/profile/Shibboleth/SSO"  
            
          end
          
          ## What sort of IDP software is this meant to be?
          def idp_type
            
            return :shibboleth2
            
          end
          
          ## Default landing page, login, and / redirection
          def default_url
            
            return build_sim_url("/")
          
          end
          
          ## Login path
          def login_url

            return build_sim_url(idp_base_path, login_path)
          
          end
          
          ## SLO path
          def logout_url

            return build_sim_url(idp_base_path, logout_path)
          
          end
          
          ## Shibboleth1-style "OK" page
          def old_status_url
   
            return build_sim_url(idp_base_path, old_status_path)
                    
          end
          
          ## Shibboleth 2 style text
          def new_status_url

            return build_sim_url(idp_base_path, new_status_path)
          
          end
          
          ## AuthnRequest endpoint
          def authn_url

            return build_sim_url(idp_base_path, authn_path)
          
          end
          
          def service_type_base_path
            
            return IDPService.config.sim_idp_base_path
            
          end
          
          def sso?
            
            return sso
            
          end
          
          ## Produce a feeble, inaccurate but functionally equivalent WAYFless URL for this IDP and your SP
          def wayfless_url
            
            return "wayfless URL will go here"
            
          end
          
          def map_attribute(attribute)
            
            unless @attribute_map
              
              ## Load attribute map
              attribute_maps = YAML.load(File.open(IDPService.config.sim_idp_attr_mappings_file))
              @attribute_map = attribute_maps[entity_id] || attribute_maps['default']
              
            end
            
            return @attribute_map[attribute.downcase]
            
          end
          
        end
      end
    end
  end
end
