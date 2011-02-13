module Shibkit
  module Rack
    class Simulator
      module Model
        class SPSession
          
          ## Easy access to Shibkit's configuration settings
          include Shibkit::Configured 
          
          ## Add the record processing mixin if it's present
          #load_filter_mixin
          
          ## A new SPSession
          def initialize(env)
            
            ## Store reference to the Rack session: all object data will be stored
            ## in here - this class is really just an interface to part of session
            ## and aspects of configuration 
            @env = env
            
            ## Make sure we have a data structure
            @env['rack.session']['shibkit-simulator']       ||= Hash.new
            @env['rack.session']['shibkit-simulator']['sp'] ||= Hash.new
            
            ## A default SP service that uses the config for values
            @sp_service = Shibkit::Rack::Simulator::Model::SPService.new
            
            ## Replace it with one configured from real metadata?
            if config.sim_sp_use_metadata
              
              begin
               @sp_service = Shibkit::Rack::Simulator::Model::SPService.find_by_entity(config.entity_id)
              rescue

                ## TODO need to raise exception here to deal with bad IDP ID.
                raise Rack::Simulator::ResourceNotFound, "Unable to find SP '#{config.entity_id}' in metadata"

              end 
            end
            
          end
          
          ## Declare that the user has logged in to the SP
          def login!(idp_assertion)

            sp_session[:user_id]     = idp_assertion.sim_user_id
            sp_session[:login_time]  = Time.new
            sp_session[:access_time] = sp_session[:login_time]
            
            ## Construct a new session ID 
            sp_session[:session_id] = Shibkit::DataTools.xsid
            
          end
          
          ## Access the SP with an already authentication session
          def access!
            
            sp_session[:access_time] = Time.new
            
          end
          
          ## Clear session for user
          def logout!
            
            reset!
            
          end

          ## Wipe SP session contents clean
          def reset!
            
            sp_session.replace(Hash.new)
            
          end

          ## Is the specified user logged in at the SP?
          def logged_in?(user_id)

            return false if expired?
            
            ## Has the fake IDP 'authenticated'?
            return false unless sp_session[:user_id].to_i > 0

            ## Check that the *same* user has already authenticated with the fake SP too.
            #return true if env["rack.session"]['shibkit-simulator']['idp'][:user_id].to_i == 
            #  sim_sp_session(env)[:user_id].to_i
            #return false
            
            
            return sp_session[:user_id] == user_id

          end
          
          alias :authenticated? :logged_in?
          

          
          ## When did the user first login? 
          def login_time
            
            return sp_session[:login_time]
            
          end
          
          ## Time of most recent page view before this request
          def previous_access_time
            
            return sp_session[:access_time]
            
          end
          
          ## SP session ID
          def session_id
            
            return sp_session[:session_id]
            
          end
          
          ## Time when session expires
          def session_expires

            return Time.new - sp_session[:login_time]

          end

          ## How long has this session been idle? (in minutes)
          def session_idle

            return Time.new - Time.login

          end      
          
          ## Has the session expired?
          def expired?
            
            return false if Time.new < session_expires
            
          end
          
          ## Details about the user passed by IDP
          def idp_assertion
            
            return sp_session[:idp_assertion]
            
          end
          
          ## Remember destination
          def remember_destination(destination)
            
            sp_session[:destination] = destination
            
          end
          
          ## Where is the user trying to go to?
          def destination
            
            return sp_session[:destination] || request.path || config.home_path
            
          end
          
          ## Returns hash of attribute headers as they would be injected
          def attribute_headers

            headers = Hash.new
            
            #raise Rack::Simulator::RuntimeError, "Missing user details when trying to add SP headers" unless user_details
            
            ## Convert to proper format that matches the live SP (also add new ones)
            prepared_data = process_attribute_data(idp_assertion.something) # TODO

            ## Now the useful bit
            prepared_data.each_pair do | header, value| 

              headers[header] = value

            end

            ## Inject the rather important eptid varieties
            headers['targeted-id']   = prepared_data['targeted_id']   || 
              Shibkit::DataTools.targeted_id(user_details['id'], sp_id, user_details['idp_scope'], user_details['idp_salt'], type=:computed)
            headers['persistent-id'] = prepared_data['persistent_id'] ||
              Shibkit::DataTools.persistent_id(user_details['id'], sp_id, user_details['idp_id'], user_details['idp_salt'], type=:computed)
  
            ## Cache the persistent ID for this user # TODO ? 
            #user_details['persistent_id'] = headers['persistent-id']
          
            
            return headers

          end

          ## Returns hash of session headers as they would be injected
          def session_headers
            
            headers = Hash.new
            
            ## Application ID
            headers['Shib-Application-ID'] = 'default'

            ## Persistent Session ID
            session_id = sp_session(env)[:session_id]
            headers['Shib-Session-ID'] = session_id

            ## Identity Provider ID
            headers['Shib-Identity-Provider'] = entity_id

            ## Time authentication occured as a string in xs:DateTime format (with no timezone for some reason)  # TODO
            headers['Shib-Authentication-Instant'] = login_time.xmlschema.gsub(/(\+.*)/, 'Z')

            ## Keep login method rather vague # TODO
            headers['Shib-Authentication-Method'] = 'urn:oasis:names:tc:SAML:1.0:am:unspecified'
            headers['Shib-AuthnContext-Class']    = 'urn:oasis:names:tc:SAML:1.0:am:unspecified'

            ## Assertion headers are cargo-culted for not (not sensible - Do Not Use)
            assertion_header_info(session_id, user_details).each_pair {|header, value| env[header] = value}
            headers['Shib-Assertion-Count'] = "%02d" % assertion_header_info(session_id, user_details).size

            ## Is targeted ID set to be automatic?
            headers['REMOTE_USER'] = user_details['persistent_id'] ||
              Shibkit::DataTools.persistent_id(user_details['id'],
                sp_id, user_details['idp_id'],
                user_details['idp_salt'],
                type=:computed)
            
            ## This is pure cargo-cult nonsense but enhances the fakery (at some point real assertion parts should be faked, maybe?)
            ## This should be based on total size of assertion data I believe (this is Shib1.3 style?)
            (1..2).each do |assertion_part|

              ## Each assertion fragment gets a numbered identifier
              header = 'Shib-Assertion-' + "%02d" % assertion_part

              ## Building up a mock URL
              value  = config.sim_assertion_base + '?key=' + session_id + '&ID=' + Shibkit::DataTools.xsid

              ## Collect it
              headers[header] = value

            end
            
            return headers
            
          end

          ## Copy headers for session and user attributes, etc into Rack session
          def inject_headers!
            
            session_headers.each_pair {|header, value| @env[header.to_s] = value.to_s}
            
            attribute_headers.each_pair {|header, value| @env[header.to_s] = value.to_s}
            
          end
          
          ## Remove all injected headers
          def flush_headers!

            session_headers.each_key   { |header| @env[header.to_s] = nil }
            
            attribute_headers.each_key { |header| @env[header.to_s] = nil }
          
          end
          
          ## The SP service
          def sp_service
            
            return @sp_service
            
          end
          
          def required?
            
            return sp_service.required_session?
            
          end
          
          def lazy?
            
            return sp_service.lazy_session?
            
          end
          
          ## 
          
          private 
          
          ## Convenient accessor to this object's session data
          def sp_session
            
            return @env['rack.session']['shibkit-simulator']['sp'] 
            
          end
          
          ## Munge the data in attributes to match Shib/SAML expectations
          def process_attribute_data(user_details)

            munged_data = user_details.dup

            ## Call out to filter (this is monkey patched by shibsim_filter.rb)
            munged_data = user_record_filter(munged_data)

            return munged_data

          end
          
          ## User-overridable method - monkey patch with shibsim_filter.rb
          def user_record_filter(munged_data)

            return munged_data

          end
          
        end
      end
    end
  end
end
  

