module Shibkit
  module Rack
    class Simulator
      module Model
        class IDPSession

          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
          
          attr_reader :idp_service
            
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
            @env['rack.session']['shibkit-simulator'][:active_user]      = nil 
            @env['rack.session']['shibkit-simulator']['idps']          ||= Hash.new
            @env['rack.session']['shibkit-simulator']['idps'][@idp_id] ||= Hash.new
            
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
          def login!(user_id=active_user)

            idp_session[:user_id]     = idp_assertion.sim_user_id
            idp_session[:idp_id]      = "" # TODO
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

            ## Check that the *same* user has already authenticated with the fake SP too.
            #return true if env["rack.session"]['shibkit-simulator']['idp'][:user_id].to_i == 
            #  sim_idp_session(env)[:user_id].to_i
            #return false
           
           
            return idp_session[:user_id] == user_id

         end

         ## Has the session expired?
         def expired?
           
           return false if Time.new < session_expires
           
         end

         ## When did the user first login? 
         def login_time
           
           return idp_session[:login_time]
           
         end
         
         ## Time of most recent page view before this request
         def previous_access_time
          
           return idp_session[:access_time]
           
         end
         
         ## SP session ID
         def session_id
           
           return idp_session[:session_id]
           
         end
         
         ## Time when session expires
         def session_expires

           return Time.new - idp_session[:login_time]

         end

         ## How long has this session been idle? (in minutes)
         def session_idle

           return Time.new - Time.login

         end
            
         ## When did the user first login? 
         def login_time
           
           return idp_session[:login_time]
           
         end
         
         ## Time of most recent page view before this request
         def previous_access_time
           
           return idp_session[:access_time]
           
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
         
         ## Location of the fake SP's session status page
         def login_path
        
           return "/login"

         end


         ## Location of the fake SP's session status page
         def logout_path

           return "/logout"

         end
         
         
         ## Location of the fake SP's session status page
         def new_status_path

           return IDPSession.config.sim_idp_new_status_path

         end
         
         ## Location of the fake SP's session status page
         def old_status_path

           return IDPSession.config.sim_idp_old_status_path

         end
              
         ## Location of the fake SP's session status page
         def session_path

           return IDPSession.config.sim_idp_session_path

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

