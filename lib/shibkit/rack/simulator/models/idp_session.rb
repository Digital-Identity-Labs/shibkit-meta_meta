module Shibkit
  module Rack
    class Simulator
      module Model
        class IDPSession

          ## Easy access to Shibkit's configuration settings
          include Shibkit::Configured
            
          ## A new IDP Session
          def initialize(env)
  
            ## Store reference to the Rack session: all object data will be stored
            ## in here - this class is really just an interface to part of session
            ## and aspects of configuration 
            @env = env
  
            ## Make sure we have a data structure
            @env['rack.session']['shibkit-simulator']        ||= Hash.new
            @env['rack.session']['shibkit-simulator']['idp'] ||= Hash.new
  
          end
  
          ## Declare that the user has logged in to the SP
          def login!(user_id)

            idp_session[:user_id]     = idp_assertion.sim_user_id
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
         def logged_in?(user_id)

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

         ## Location of the fake SP's session status page
         def login_path
        
           return config.sim_idp_path + "/login"

         end


         ## Location of the fake SP's session status page
         def logout_path

           return config.sim_idp_path + "/logout"

         end
         
         
         ## Location of the fake SP's session status page
         def new_status_path

           return config.sim_idp_session_path

         end
         
         ## Location of the fake SP's session status page
         def old_status_path

           return config.sim_idp_session_path

         end
              
         ## Location of the fake SP's session status page
         def session_path

           return config.sim_idp_session_path

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

          return config.sim_sp_entity_id

         end
       
         ## Does the IDP allow Single Sign On?
         def sso?

           ## Can Chooser IDPs have Single Sign On? # TODO needs per-IDP settings too
           return config.sim_chooser_idp_sso

         end

         ## Fetch information from directory and hand over
         def assertion
   
           return idp_session[:idp_assertion]
   
         end

         private
       
         ## Convenient accessor to this object's session data
         def idp_session
         
           return @env['rack.session']['shibkit-simulator']['idp'] 
         
         end

       end
     end
   end
 end
end

