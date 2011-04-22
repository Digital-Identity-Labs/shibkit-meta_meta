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
            
            request = ::Rack::Request.new(env)
            
            ## Store destinatation
            sp_session[:destination] ||= request.path
            
            ## Replace it with one configured from real metadata?
            if config.sim_sp_use_metadata
              
              begin
               @sp_service = Shibkit::Rack::Simulator::Model::SPService.find_by_entity(config.entity_id)
              rescue

                ## TODO need to raise exception here to deal with bad IDP ID.
                raise Shibkit::Rack::ResourceNotFound, "Unable to find SP '#{config.entity_id}' in metadata"

              end 
            end
            
          end
          
          ## Declare that the user has logged in to the SP
          def login!(encoded_assertion)

            idp_assertion = YAML.load(Base64.decode64(encoded_assertion))

            sp_session[:encoded_assertion]  = encoded_assertion
            sp_session[:idp_auth_assertion] = idp_assertion
            sp_session[:idp_attr_assertion] = idp_assertion
            sp_session[:login_time]         = Time.new
            sp_session[:access_time]        = sp_session[:login_time]
            
            ## Construct a new session ID 
            sp_session[:session_id] = Shibkit::DataTools.xsid
            
            return true
            
          end
          
          def assertion_count(format=false)
            
            count = idp_auth_assertion == idp_attr_assertion ? 1 : 2
            
            if format
              return "%02d" % count
            else
              return count
            end
            
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
          def logged_in?

            return false unless idp_auth_assertion
            return false if expired?
            
            return true

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
          
          def remote_user
            
            config.sim_remote_user.each do |id_attribute|
              
              username =  attributes[id_attribute]
              
              return username if username 
              
            end
            
            return ""
            
          end
          
          def lifetime
            
            return config.sim_sp_session_lifetime
            
          end
          
          ## Minutes until expiry
          def minutes_until_expiry
            
            login_secs = login_time.to_i
            return ((login_secs + lifetime) - Time.new.to_i) / 60

          end
          
          def expiry_time
            
            return access_time + config.sim_sp_session_lifetime 
            
          end
          
          ## How long has this session been idle? (in minutes)
          def idleness_limit

            return config.sim_sp_session_lifetime

          end      
          
          ## How long has the session been idle?
          def idleness
            
            return Time.new.to_i - login_time.to_i
            
          end
          
          ## Has the session expired?
          def expired?
            
            return false #true if Time.new.to_i > session_expires
            return false
            
          end
          
          def identity_provider
            
            return idp_auth_assertion.identity_provider
            
          end
          
          ## Details about the user passed by IDP (auth, with or without attribs)
          def idp_auth_assertion
            
            return sp_session[:idp_auth_assertion]
            
          end
          
          ## Details about the user passed by IDP (second/auth assertion or copy of first)
          def idp_attr_assertion
            
            return sp_session[:idp_attr_assertion]
            
          end

          
          ## Remember destination
          def remember_destination(destination)
            
            sp_session[:destination] = destination
            
          end
          
          ## Remember destination
          def destination
            
            return sp_session[:destination]
            
          end
          
          ## Where is the user trying to go to?
          def target
            
            return sp_session[:destination] || config.home_path
            
          end
          
          def target_cookie
            
            
            
          end
          
          def encoded_assertion
            
            return sp_session[:encoded_assertion]
            
          end
          
          ## Returns hash of attribute headers as they would be injected
          def attributes
           
            mapped_attributes = Hash.new
           
            idp_attr_assertion.attributes.each_pair do |attribute, value|
               
              attr_name = sp_service.map_attribute(attribute)
              
              value = value.join(';') if value.kind_of?(Array)
              
              mapped_attributes[attr_name] = value if attr_name
                
            end
            
            tid = mapped_attributes['targeted-id']
            mapped_attributes['targeted-id'] = 
              [tid, idp_attr_assertion.scope].join('@') if tid ## TODO: move join to Data_tools
            
            pid =  mapped_attributes['persistent-id']
            mapped_attributes['persistent-id'] = 
              [idp_attr_assertion.identity_provider, sp_service.uri, pid].join('!') if pid ## TODO: move join to Data_tools
            
            return mapped_attributes
            
          end

          ## Returns hash of session headers as they would be injected
          def session_variables
            
            vars = Hash.new
            
            return vars unless logged_in?
            
            ## Application ID
            vars['Shib-Application-ID'] = sp_service.application_id

            ## Persistent Session ID
            vars['Shib-Session-ID'] = session_id

            ## Identity Provider ID
            vars['Shib-Identity-Provider'] = identity_provider

            ## Time authentication occured as a string in xs:DateTime format (with no timezone for some reason)  # TODO
            vars['Shib-Authentication-Instant'] = idp_auth_assertion.auth_instant.utc.xmlschema
            
            ## Keep login method rather vague # TODO
            vars['Shib-Authentication-Method'] = idp_auth_assertion.auth_method || 'none' ## TODO: need to fix these for Lazy sessions
            vars['Shib-AuthnContext-Class']    = idp_auth_assertion.auth_class || idp_auth_assertion.auth_method

            ## Is targeted ID set to be automatic?
            vars['REMOTE_USER'] = remote_user
            
            ## Assertion headers are cargo-culted for not (not sensible - Do Not Use)
            #assertion_header_info(session_id, user_details).each_pair {|header, value| env[header] = value}
            vars['Shib-Assertion-Count'] = assertion_count(:formatted)
            
            ## Building up a mock assertion ID URLs
            vars['Shib-Assertion-001']  = sp_service.assertion_url + 
              '?key=' + session_id + '&ID=' + idp_auth_assertion.id
            vars['Shib-Assertion-002']  = sp_service.assertion_url + 
              '?key=' + session_id + '&ID=' + idp_attr_assertion.id if assertion_count == 2  
            
            return vars
            
          end

          ## Copy headers for session and user attributes, etc into Rack session
          def inject_variables!
            
            session_variables.each_pair {|label, value| @env[prep_label(label)] = value.to_s}       
            attributes.each_pair {|label, value| @env[prep_label(label)]        = value.to_s}
            
          end
          
          ## Remove all injected headers/CGI variables
          def flush_variables!

            session_variables.each_pair {|label, value| @env[prep_label(label)] = nil}       
            attributes.each_pair {|label, value| @env[prep_label(label)]        = nil}
          
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
          
          def prep_label(label)
            
            ## Change keys to mimic the IIS header bodge/workaround
            return config.iis_headers ? "HTTP_" + label.upcase.gsub('-','_') : label
  
          end
          
          ## Convenient accessor to this object's session data
          def sp_session
            
            return @env['rack.session']['shibkit-simulator']['sp'] 
            
          end
          
        end
      end
    end
  end
end
  

