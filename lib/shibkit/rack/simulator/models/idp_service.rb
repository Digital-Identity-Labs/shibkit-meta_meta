require 'shibkit/rack/simulator/models/entity_service'

module Shibkit
  module Rack
    class Simulator
      module Model
        class IDPService < EntityService
          
          setup_storage
          
          attr_accessor :scopes
          attr_accessor :scope
          attr_accessor :auth_attribute
          attr_accessor :pid_attribute
          attr_accessor :auth_method_uri
          attr_accessor :auth_class_uri
          attr_accessor :add_tid
          attr_accessor :directory
          
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
          def from_defaults(default_list)
          
            
          
          end
          
          ## What sort of IDP software is this meant to be?
          def idp_type
            
            return :shibboleth2
            
          end
          
          ## Default landing page, login, and / redirection
          def default_path
            
            return "/"
          
          end
          
          ## Login path
          def login_path

            return "/logout"
          
          end
          
          ## SLO path
          def logout_path

            return "/logout"
          
          end
          
          ## Shibboleth1-style "OK" page
          def old_status_path
   
            return "/idp/profile/Status"
                    
          end
          
          ## Shibboleth 2 style text
          def new_status_path

            return "/idp/status"
          
          end
          
        end
      end
    end
  end
end
