require 'shibkit/rack/simulator/models/entity_service'

module Shibkit
  module Rack
    class Simulator
      module Model
        class SPService #< Session
          
          ## Easy access to Shibkit's configuration settings
          include Shibkit::Configured 
          
          ## Copy data from a suitable MetaMeta object
          def from_metadata(entity)
          
            ## Override current config 
            @from_metadata = true
                
          end
          
          def application_name
            
            return @application_name || config.app_name
            
          end  
             
          def home_path
            
            return @home_path || config.home_path
            
          end  
           
          def exit_path
            
            return @exit_path || config.exit_path
            
          end  

          def handler_path
            
            return @handler_path || config.handler_path
            
          end  
                  
          ## URL paths that are protected by Shibboleth
          def protected_paths
            
            return @protected_paths || config.protected_paths
            
          end
          
          ## Location of the fake SP's general status page
          def status_path

            return @status_path || config.handler_path + config.session_path

          end
                   
          ## Location of the fake SP's session status page
          def session_path

            return @session_path || config.handler_path + config.session_path

          end
          
          ## Location of the fake SP's login path / SessionInitiator URL
          def login_path

            return @login_path || config.handler_path + config.login_path

          end
          
          ## Location of the fake SP's logout page
          def logout_path

            return @logout_path || config.handler_path + config.logout_path

          end
          
          ## The Shibboleth SP application label (defaults to default)
          def application_id

            return @application_id || config.sim_application

          end
          
          ## The Shibboleth SP entity ID
          def entity_id

            return @entity_id || config.entity_id

          end
         
          ## Content protection mode (:active or :passive)
          def content_protection
            
            return @content_protection || @config.content_protection
            
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
