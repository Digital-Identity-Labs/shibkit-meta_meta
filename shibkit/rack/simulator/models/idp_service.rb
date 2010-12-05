require 'shibkit/rack/simulator/models/entity_service'

module Shibkit
  module Rack
    class Simulator
      module Model
        class IDPService < EntityService
          
          setup_storage
          
          attr_accessor :scopes
          attr_accessor :auth_attribute
          attr_accessor :pid_attribute
          attr_accessor :auth_method_uri
          attr_accessor :auth_class_uri
          attr_accessor :idp_type
          attr_accessor :add_tid
          attr_accessor :directory
          
          ## Copy data from a suitable MetaMeta object
          def from_metadata(entity)
          
            @display_name  = entity.organisation.display_name
            @uri           = entity.entity_uri
            @metadata_id   = entity.metadata_id
            @url           = entity.organisation.url
            @scopes        = entity.scopes
            
          end
          
          ## Set properties from a list of defaults
          def from_defaults(default_list)
          
            
          
          end
          
          ## Returns Directory for this organisation
          def directory
            
            
            
          end
          
          
          
        end
      end
    end
  end
end
