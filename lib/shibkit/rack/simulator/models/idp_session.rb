module Shibkit
  module Rack
    class Simulator
      module Model
        class IDPSession #< Session
          
          require 'shibkit/rack/simulator/models/idp_authn_request'
          require 'shibkit/rack/simulator/models/idp_saml_response'
          
          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
          
          attr_reader :idp_service
          attr_reader :active_user
          attr_reader :idp_id

          ## A new IDP Session
          def initialize(env, idp_id)
  
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
          
          ## Store authn_request object
          def authn_request=(req)
            
            idp_session[:authn_request] = req
            
          end
          
          ## Get authn_request object
          def authn_request
            
            return idp_session[:authn_request] || nil
            
          end
          
          ## Declare that the user has logged in to the SP
          def login!(username)
            
            ## Construct a new session ID 
            idp_session[:session_id] = Shibkit::DataTools.xsid       
            idp_session[:principal]   = username
            idp_session[:login_time]  = Time.new
            idp_session[:access_time] = idp_session[:login_time]
             
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

          ## Username
          def principal
           
            return idp_session[:principal]
           
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
         
          ## Session expires at...
          def session_expires
           
          end

          ## Fetch information from directory and hand over
          def assertion(sp_entity_id,attributes=false)
   
            assertion = Shibkit::Rack::Simulator::Model::IDPSAMLResponse.new
              
            assertion.session_id         = session_id
            assertion.identity_provider  = idp_service.uri 
            assertion.auth_instant       = login_time
            assertion.audience           = sp_entity_id
            assertion.name_identifier    = "NOTIMPLEMENTEDYET" 
            assertion.auth_method        = idp_service.auth_method_uri
            assertion.attributes         = attributes
            
            return assertion
   
          end
          
          ## Return attributes from directory, processed into appropriate format
          def attributes
            
            mapped_attributes = Hash.new
            
            user_entry = idp_service.directory.lookup_account(principal)
            user_entry.attributes.each_pair do |attribute, value|
              
              mapped_attributes[idp_service.map_attribute(attribute)] = value if value
              
            end
            
            return mapped_attributes
            
          end
          
          ## Shibsim base location of the IDP
          def service_base_path
           
            return IDPSession.config.sim_idp_base_path + idp_id

          end
          
          ## ? # TODO: Need this? Refactor to base class for sessions?
          def set_message(message)
            
            idp_session[:message] = message
            
          end
          
          ## ? # TODO: Need this? Refactor to base class for sessions?
          def get_message
            
            message = idp_session[:message] || nil
            idp_session.delete(:message) if idp_session[:message]
            
            return message
            
          end
          
          private
       
          # TODO: Refactor this into a session base class.
          ## Convenient accessor to this object's session data ## TODO: not DRY - refactor into base class
          def idp_session
         
            return @env['rack.session']['shibkit-simulator']['idps'][@idp_id]
         
          end
         
       end
     end
   end
 end
end

