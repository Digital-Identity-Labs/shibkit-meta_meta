require 'shibkit/rack/simulator/models/entity_service'

module Shibkit
  module Rack
    class Simulator
      module Model
        class SPService 

          require 'shibkit/rack/base/mixins/http_utils'
          
          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
          
          include Shibkit::Rack::Base::Mixin::HTTPUtils
          
          ## Copy data from a suitable MetaMeta object
          def from_metadata(entity)
          
            ## Override current config 
            @from_metadata = true
                
          end
          
          def application_name
            
            return @application_name || SPService.config.app_name
            
          end  
          
          def protocols
            
            return @protocols || SPService.config.protocols
            
          end
          
          def home_path
            
            return @home_path || SPService.config.home_path
            
          end  

          def home_url
            
            return @home_path || build_sim_url(SPService.config.home_path)
            
          end
         
          def exit_path
            
            return @exit_path || SPService.config.exit_path
            
          end
            
          def exit_url
            
            return @exit_path || build_sim_url(SPService.config.exit_path)
            
          end
          
          def handler_path
            
            return @handler_path || SPService.config.handler_path
            
          end  
          
          def handler_url
            
            return @handler_path || build_sim_url(SPService.config.handler_path)
            
          end   
               
          ## URL paths that are protected by Shibboleth (as literal strings)
          def protected_paths
            
            return @protected_paths || SPService.config.protected_paths
            
          end
          
          ## Paths to protect converted into regular expressions
          def protected_path_patterns
          
            @recache ||= Hash.new

            ppp = :protected_path_patterns

            unless @recache[ppp]
              
              @recache[ppp] ||= protected_paths.collect { |p| /#{"^" + p}/ }

            end

            return @recache[ppp]
                    
          end
          
          ## Location of the fake SP's general status page
          def status_path

            return @status_path || glue_paths(SPService.config.handler_path, SPService.config.status_handler)

          end

          ## Location of the fake SP's general status page
          def status_url

            return @status_path || build_sim_url(SPService.config.handler_path, SPService.config.status_handler)

          end
          
          ## Location of the fake SP's Metadata page
          def metadata_path

            return @metadata_path || glue_paths(SPService.config.handler_path, SPService.config.metadata_handler)

          end          

          ## Location of the fake SP's Metadata page
          def metadata_url

            return @metadata_path || build_sim_url(SPService.config.handler_path, SPService.config.metadata_handler)

          end

          ## Location of the fake SP's 
          def wayf_url

            return @metadata_path || build_sim_url(SPService.config.handler_path, SPService.config.wayf_handler)

          end

          ## Location of the fake SP's 
          def ds_url

            return @metadata_path || build_sim_url(SPService.config.handler_path, SPService.config.ds_handler)

          end

          ## Location of the fake SP's 
          def df_url

            return @metadata_path || build_sim_url(SPService.config.handler_path, SPService.config.df_handler)

          end
                          
          ## Location of the fake SP's session status page
          def session_path

            return @session_path || glue_paths(SPService.config.handler_path, SPService.config.session_handler)

          end

          ## Location of the fake SP's session status page
          def session_url

            return @session_path || build_sim_url(SPService.config.handler_path, SPService.config.session_handler)

          end

          ## Location of the fake SP's login path / SessionInitiator URL
          def login_path

            return @login_path || glue_paths(SPService.config.handler_path, SPService.config.login_handler)

          end

          ## Location of the fake SP's login path / SessionInitiator URL
          def login_url

            return @login_path || build_sim_url(SPService.config.handler_path, SPService.config.login_handler)

          end

          ## Location of the fake SP's logout page
          def logout_path

            return @logout_path || glue_paths(SPService.config.handler_path, SPService.config.logout_handler)

          end

          ## Location of the fake SP's logout page
          def logout_url

            return @logout_path || build_sim_url(SPService.config.handler_path, SPService.config.logout_handler)

          end

          def sso_path
            
            return @sso_uri || glue_paths(SPService.config.handler_path, SPService.config.sso_handler)
            
          end

          def sso_url
            
            return @sso_uri || build_sim_url(SPService.config.handler_path, SPService.config.sso_handler)
            
          end
          
          ## The Shibboleth SP application label (defaults to default)
          def application_id

            return @application_id || SPService.config.sim_application

          end
          
          ## The Shibboleth SP entity ID
          def entity_id

            return @entity_id || SPService.config.entity_id

          end
          
          alias :uri :entity_id
          
          ## Content protection mode (:active or :passive)
          def content_protection
            
            return @content_protection || SPService.config.content_protection
            
          end 
          
          ## Is an authenticated session required for the entire application? (:active content protection mode)
          def required_session?
          
            return content_protection == :active 
          
          end
          
          ## Is the SP using lazt sessions? (:passive protection mode)
          def lazy_session?
          
            return content_protection == :active
          
          end
          
          def map_attribute(attrib)
            
            unless @attribute_map

              ## Load attribute map
              attribute_maps = YAML.load(File.open(IDPService.config.sim_sp_attr_mappings_file))
              @attribute_map = attribute_maps[SPService.config.sim_sp_attr_mapper.to_s]
              raise "No SP attribute mapper!" unless @attribute_map.kind_of?(Hash)

            end
            
            return @attribute_map[attrib.to_s.downcase]
            
            
          end
          
          ## Build a full URL (will be various options to change this later TODO)
          def build_sim_url(*path_fragments)
            
            ## Assuming :numeric type for now
            
            scheme   = "http://" ## TODO: Need switch for HTTPS (see config)
            hostname = "localhost"
            port     = 3000.to_s
            
            full_path = glue_paths(service_type_base_path, *path_fragments)
            
            url = scheme + hostname + ":" + port + full_path
             
            return url
            
          end
          
          def service_type_base_path
            
            return ""
            
          end
          
        end
      end
    end
  end
end
