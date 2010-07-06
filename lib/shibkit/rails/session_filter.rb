require 'shibkit/sp_assertion'

module Shibkit
  module Rails
    module SessionFilter
      
      ## Redirect users to login here
      GATEWAY_URL=nil
      
      ## Redirect failed logins here
      EXIT_URL=nil
      
      ## Just class methods from here on
      class << self
          
        ## Filter method called by the controller (entry point)
        def filter(controller)
          
          ## First request? Initialize a few things to get the ball rolling
          initialize_session(controller) unless controller.session[:first_access_at]
                   
          ## Check session consistency (basic paranoia)
          return unless session_integrity_checks(controller) 
          
          ## Do not authenticate if we already have a valid authenticated session
          unless valid_session?(controller)
            
            ## Check that basic conditions are OK before we start to authenticate
            preauthentication_checks(controller)
          
            ## Authentication: Make sure we have a shib_user object
            sp_authentication(controller)
          
            ## Is user allowed to access this application?
            site_authorisation(controller)
          
            ## Load details into application database
            update_user_details(controller)
          
            ## Application authorisation setup
            application_authorisation_setup(controller)
            
          end
          
          ## Sentient User support
          inform_user_aware_models(controller)
          
          ## Tidy up session, simple updates
          complete_session_update(controller)
          
        end
    
        ## First login? Initialize a few things to get the ball rolling
        def initialize_session(controller)
          
          ::Rails.logger.info "Session Filter: Session Filter: Initializing session..."
          
          ## Record the originating IP address to help prevent hijacking
          controller.session[:ip_address] = controller.request.remote_ip
          
          ## We'll record login attempts
          controller.session[:failed_logins] = 0
          
          ## Log first access time here
          controller.session[:first_access_at] = Time.new
          
          ## Set first expiry time for session (forces update from SP or reauth)
          controller.session[:expires_at] = controller.session[:first_access_at] + 5.minutes
          
          ## Remember original destination URL
          controller.session[:original_destination] = controller.request.url
          
          ::Rails.logger.info "Session Filter: New session from #{controller.session[:ip_address]} at #{controller.session[:first_access_at]} "
          
        end

        ## Check basic session consistency (paranoia: destroy if strange)
        def session_integrity_checks(controller)
          
          reset = false

          ## If session has expired, destroy it so it will be rebuilt
          reset = true if (controller.session[:expires_at] < Time.new)
          
          ## If session has changed IP addresses destroy it, unless it has been proxied. # TODO: fix proxy compat.
          reset = true if controller.session[:ip_address] != controller.request.remote_ip
          
          ## 
          
          ## The actual reset bit. # <- should I handle with an exceptiona and halt?
          if reset
            
            ## Keep track, in case this is repeatedly happening
            session_error_count = controller.session[:session_errors] || 0
            
            ## Wipe all session data
            ::Rails.logger.info "Session Filter: Resetting session because it was inconsistent"
            controller.reset_session
            
            ## Keep track of this...
            controller.flash[:warning] = "Your session has been reset"
            controller.session[:session_errors] ||= session_error_count
            controller.session[:session_errors] += 1
            
            ## Redirect to start again
            controller.redirect_to controller.session[:original_destination] || '/'
            
            return false
            
          end
          
          return true
          
        end
        
        ## Do nothing if we already have a valid session
        def valid_session?(controller)
          
          valid = true
          
          ## We must have an SP object
          valid = false unless controller.session[:sp_session] and 
            controller.session[:sp_session].kind_of?(Shibkit::SPAssertion)
          
          ## We must have a user_id in session - if not then auth is not complete
          valid = false unless controller.session[:user_id] and controller.session[:user_id].to_i > 0 
          
          ## Only lookup user unless things still OK, and we actually have an ID for a user
          if valid and controller.session[:user_id].to_i > 0
          
            ## SP object *must* match the user model core ID if it is present (to prevent SP reauth not being in sync with application)
            valid = false unless User.find(controller.session[:user_id]).persistent_id == controller.session[:sp_session].persistent_id
          
          end
          
          ## If session isn't valid we do a few things then return false
          unless valid 
            
            ## Record failed login
            controller.session[:failed_logins] ||= 0
            controller.session[:failed_logins] += 1
            
            ::Rails.logger.info "Session Filter: No valid authenticated session exists (count: #{controller.session[:failed_logins]})"
            
            return false
    
          end
          
          ::Rails.logger.info "Session Filter: Valid existing authenticated session has been found" 
          
          ## All clear, so return true
          return true
          
        end
        
        ## Check that basic conditions are OK
        def preauthentication_checks(controller)
          
          ## Check for simultaneous logins from different addresses with time period.
          # ... this involves using the logs, so TODO later.
          

          #return true
          
        end
        
        ## Authentication: Make sure we have an sp_session, maybe trigger gateway redirect
        def sp_authentication(controller)
          
          ## Do we have an SP user assertion object?
          sp_session = controller.session[:sp_session]
          #raise unless sp_session.kind_of?(Shibkit::SPAssertion)        
          
          ## TODO... lots.
          
          ## Fail with an error if we are at the gateway action (only if gatewayed)
          # ...
                    
          ## Redirect to the login page if we are in gateway mode and not at gateway
          # ...
          
          return true

        end
        
        ## Is user allowed to access this application?
        def site_authorisation(controller)
          
          ## Get the organisation settings for this user
          # ...
          
          ## Check the organisation settings 
          # ...
          
          ## Raise suitable exception
          
          return true

        end
        
        ## Load details into application database
        def update_user_details(controller)
          
          ::Rails.logger.info  "Session Filter: Preparing to update current user details"

          ## Try to get the user details
          sp_assertion = controller.session[:sp_session]

          raise "Session Filter: Missing user data! Can't find SP assertion object" unless sp_assertion
          user = nil
          
          begin
            
            ## Try to get an existing record
            user = User.find_or_initialize_by(:persistent_id => sp_assertion.persistent_id)
            
            ::Rails.logger.info  "Session Filter: Found existing user with id #{sp_assertion.persistent_id}"
            
          rescue Mongoid::Errors::DocumentNotFound
            
            ## <- Not needed? Change to error handler? 
            
            ## Create a new user
            user = User.new
            
          end
          
          ## Upate information (rely on IDP to make sure this is the same user)
          user.sp_session_id  = sp_assertion.session_id
          user.persistent_id  = sp_assertion.persistent_id
          user.name_id        = sp_assertion.persistent_id.split('!')[2] # TODO: needs to be moved into model? FIXed anyway. This is crap.
          user.display_name   = sp_assertion.attrs.display_name
          user.org_scope      = "unknown"
          user.last_login     = controller.session[:first_access_at]
          user.email          = sp_assertion.attrs.mail
          user.id_url         = sp_assertion.attrs.url
          user.language       = sp_assertion.attrs.language
          user.org_id         = 0 # sp_assertion.attrs.org_id <- TODO: Need IDP/Org database
                 
          ## Store or create full information 
          #user.idp_assertion_id  = sp_assertion.attrs_targeted_id
          #user.public_profile_id = sp_assertion.attrs_targeted_id
          
          ## Store user at this point...
          user.save
          
          ## Store ID number of user object in session for normal things
          controller.session[:user_id] = user.id
          
          ::Rails.logger.info  "User ID #{user.id}/#{user.name_id} updated"
          
          return true

        end
        
        ## Application authorisation setup
        def application_authorisation_setup(controller)
          
          ## Placeholder for user specified subclass/mixin
          # ...
          
          return true

        end
 
        ## Set the User class to be aware of current user if supported       
        def inform_user_aware_models(controller)
          
          User.current = controller.send(:current_user) if User.respond_to?(:current)

        end
        
        ## Tidy up session, simple updates
        def complete_session_update(controller)
          
          ## Have we reached the intended destination? (at least as far as this filter is concerned)
          
          
          return true

        end
        
      end
    end
  end
end