module Shibkit
  module Rack
    class Simulator
      module Model
        class IDPSession
          
          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
          
          attr_reader :idp_service
          attr_reader :active_user
          attr_reader :idp_id
          
          ## A new IDP Session
          def initialize(env, idp_id=nil)
  
            ## Store reference to the Rack session: all object data will be stored
            ## in here - this class is really just an interface to part of session
            ## and aspects of configuration 
            @env = env
            
            ##
            @idp_id = idp_id
              
            ## Make sure we have a data structure
            @env['rack.session']['shibkit-simulator']                  ||= Hash.new
            @env['rack.session']['shibkit-simulator']['idps']          ||= Hash.new
            @env['rack.session']['shibkit-simulator']['idps'][@idp_id] ||= Hash.new
            @env['rack.session']['shibkit-simulator']['idps'][@idp_id][:idp_id] = @idp_id
            
            ## Check for limit to number of IDP sessions to prevent session overflow
            # ...
            
            ## Which IDP service are we represening  a session in?
            begin
              @idp_service = Shibkit::Rack::Simulator::Model::IDPService.find(@idp_id)
            rescue
              
              ## TODO need to raise exception here to deal with bad IDP ID.
              raise Rack::Simulator::ResourceNotFound, "Unable to find IDP '#{idp_id}'"
              
            end
            
            ## Check for old values and update them
            # ...
            
          end
              
          ## Declare that the user has logged in to the SP
          def login!(user_id)
            
            user_details = assertion
            
            idp_session[:user_id]     = assertion.sim_user_id
            idp_session[:login_time]  = Time.new
            idp_session[:access_time] = idp_session[:login_time]
           
            ## Construct a new session ID 
            #idp_session[:session_id] = Shibkit::DataTools.xsid
           
          end
         
          ## Access the SP with an already authentication session
          def access!
           
            idp_session[:access_time] = Time.new
           
          end
         
          ## Clear session for user
          def logout!
           
            reset!
           
          end

          ## Wipe SP session contents clean
          def reset!
           
            idp_session.replace(Hash.new)
           
          end

          ## Is the specified user logged in at the SP?
          def logged_in?(user_id=active_user)

            return false if expired?
           
            ## Has the fake IDP 'authenticated'?
            return false unless idp_session[:user_id].to_i > 0
           
            return idp_session[:user_id] == user_id

          end

          ## Has the session expired?
          def expired?
           
            return false #if Time.new < session_expires
           
          end

          ## When did the user first login? 
          def login_time
           
            return idp_session[:login_time] 
           
          end
         
          ## Time of most recent page view before this request
          def previous_access_time
          
           return idp_session[:access_time] || 0
           
          end
         
          ## SP session ID
          def session_id
           
            return idp_session[:session_id]
           
          end
         
          ## Time when session expires (fixed from first login time)
          def session_expires
            
           return login_time + 3600
             
          end

          ## How long has this session been idle? (in minutes)
          def session_idle

            return Time.new - previous_access_time

          end
         
          ## IP address of accessing client
          def ip_address
           
          end
         
          ## Default authentication method
          def authentication_method
           
           
          end
         
          ## Default authentication class
          def authentication_class
           
           
          end
         
          ## Session expires at...
          def session_expires
           
          end
         
          ## IDP session identifier
          def session_id

          end

          ## The Shibboleth SP entity ID
          def entity_id

            return IDPSession.config.sim_sp_entity_id

          end
       
          ## Does the IDP allow Single Sign On?
          def sso?

            ##  # TODO needs per-IDP settings too
            return true

          end

          ## Fetch information from directory and hand over
          def assertion
   
            return idp_session[:idp_assertion]
   
          end
          
          ## Shibsim base location of the IDP
          def service_base_path
           
            return IDPSession.config.sim_idp_base_path + idp_id

          end
          
          ## Shib sim location of this IDP, but with trailing /
          def service_root_path
            
            return service_base_path + '/'

          end
          
          ## Location of the fake SP's session status page
          def login_path
       
            return service_base_path + idp_service.login_path

          end

          ## Location of the fake SP's session status page
          def logout_path

            return service_base_path + idp_service.logout_path

          end
         
          ## Location of the fake SP's session status page
          def new_status_path

            return service_base_path + idp_service.new_status_path

          end
         
          ## Location of the fake SP's session status page
          def old_status_path

            return service_base_path + idp_service.old_status_path

          end
          
          ## Produce a feeble, inaccurate but functionally equivalent WAYFless URL for this IDP and your SP
          def wayfless_url
            
            return "wayfless URL will go here"
            
          end
          
          def set_message(message)
            
            idp_session[:message] = message
            
          end
          
          def get_message
            
            message = idp_session[:message] || nil
            idp_session.delete(:message) if idp_session[:message]
            
            return message
            
          end
          
          private
       
          ## Convenient accessor to this object's session data
          def idp_session
         
            return @env['rack.session']['shibkit-simulator']['idps']
         
          end
         
       end
     end
   end
 end
end

