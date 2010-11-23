require 'shibkit/rack/simulator/models/entity_service'

module Shibkit
  module Rack
    class Simulator
      module Model
        class IDPService < EntityService
          
          
          attributes :scopes
          attributes :auth_attribute
          attributes :pid_attribute
          attributes :auth_method_uri
          attributes :auth_class_uri
          attributes :idp_type
          attributes :add_tid
          
          ## Copy data from a suitable MetaMeta object
          def from_metadata(entity)
            
            puts entity.inspect
            
            display_name  = entity.organisation.display_name
            uri           = entity.entity_uri
            metadata_id   = entity.metadata_id
            url           = entity.organisation.url
            scopes        = entity.scopes
            
          end
          
          ## Set properties from a list of defaults
          def xfrom_defaults(default_list)
          
            
          
          end
          
          ## Returns Directory for this organisation
          def ldirectory
            
            
            
          end
          
          
          
        end
      end
    end
  end
end
