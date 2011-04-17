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
             
          def home_path
            
            return @home_path || SPService.config.home_path
            
          end  
           
          def exit_path
            
            return @exit_path || SPService.config.exit_path
            
          end  

          def handler_path
            
            return @handler_path || SPService.config.handler_path
            
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
                   
          ## Location of the fake SP's session status page
          def session_path

            return @session_path || glue_paths(SPService.config.handler_path, SPService.config.session_handler)

          end
          
          ## Location of the fake SP's login path / SessionInitiator URL
          def login_path

            return @login_path || glue_paths(SPService.config.handler_path, SPService.config.login_handler)

          end
          
          ## Location of the fake SP's logout page
          def logout_path

            return @logout_path || glue_paths(SPService.config.handler_path, SPService.config.logout_handler)

          end
           
          def sso_path
            
            return @sso_uri || glue_paths(SPService.config.handler_path, SPService.config.sso_handler)
            
          end
          
          def sso_url
            
            return @sso_uri || glue_paths(SPService.config.handler_path, SPService.config.sso_handler)
            
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
   
        end
      end
    end
  end
end
