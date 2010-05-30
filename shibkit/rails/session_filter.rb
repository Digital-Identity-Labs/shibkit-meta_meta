

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
          
          ## Do nothing if we already have a valid session
          unless valid_session?(controller)
          
            ## Check that basic conditions are OK
            return unless preauthentication_checks(controller)
          
            ## Authentication: Make sure we have a shib_user object
            return unless sp_authentication(controller)
          
            ## Is user allowed to access this application?
            return unless site_authorisation(controller)
          
            ## Load details into application database
            return unless update_user_details(controller)
          
            ## Application authorisation setup
            return unless application_authorisation_setup(controller)
            
          end
          
          ## Tidy up session, simple updates
          complete_session_update(controller)
          
        end
    
        ## First login? Initialize a few things to get the ball rolling
        def initialize_session(controller)
          
          ## We'll record login attempts
          controller.session[:failed_logins] = 0
          
          ## Log first access time here
          controller.session[:first_access_at] = Time.new
          
          ## Set first expiry time for session (forces update from SP or reauth)
          controller.session[:expires_at] = controller.session[:first_access_at] + 5.minutes
          
          ## Make sure various things are wiped clear
          controller.session[:sp_user] = nil
          
        end

        ## Check session consistency (paranoia: destroy if strange)
        def session_integrity_checks(controller)
          
          reset = false
          
          ## If session has expired, destroy it so it will be rebuilt
          reset = true if (controller.session[:expires_at] < Time.new)
          
          ## If session has changed IP addresses destroy it, unless it has been proxied.
          #reset = true if controller.session[:ip_address]
          
          
        end
        
        ## Do nothing if we already have a valid session
        def valid_session?(controller)
          
          valid = true
          
          ## We must have an SP object
          valid = false unless controller.session[:sp_user] and 
            controller.session[:sp_user].kind_of?(ShibUser::Assertion)
          
          ## SP object *must* match the user model core ID if it is present (to prevent SP reauth not being in sync with application)
          # ...
          
          # ...
          
          unless valid 
            
            ## Record failed login
            controller.session[:failed_logins] += 1
            
            ## Redirect to login area
            # ...
            
            return false
    
          end
          
          ## All clear
          return true
          
        end
        
        ## Check that basic conditions are OK
        def preauthentication_checks(controller)
          
          ## Check for simultaneous logins from different addresses with time period.
          # ... this involves using the logs, so TODO later.
          
          
          return true
          
        end
        
        ## Authentication: Make sure we have a shib_user object
        def sp_authentication(controller)
          
          ## Do we have an SP user assertion object?
          # ...
          
          
          ## Fail with an error if we are at the gateway action
          
          ## Redirect to the login page if we are in gateway mode
          
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
          
          puts "OK, now updating user details"
          
          ## Try to get the user details
          sp_assertion = controller.session[:sp_user]
          raise "Missing user data!" unless sp_assertion
          user = nil
          
          begin
            
            ## Try to get an existing record
            user = User.where({ :targeted_id => sp_assertion.attrs.targeted_id }).first
          
          rescue ActiveRecord::RecordNotFound
            
            ## Create a new user
            user = User.new
            
          end
          
          ## Upate information (rely on IDP to make sure this is the same user)
          user.targeted_id  = sp_assertion.attrs.targeted_id
          user.display_name = sp_assertion.attrs.display_name
          user.org_scope    = "unknown"
          user.last_login   = controller.session[:first_access_at]
          user.email        = sp_assertion.attrs.mail
          user.id_url       = sp_assertion.attrs.url
          user.language     = sp_assertion.attrs.language
          user.org_id       = sp_assertion.attrs.org_id
                 
          ## Store or create full information 
          #user.idp_assertion_id  = sp_assertion.attrs_targeted_id
          #user.public_profile_id = sp_assertion.attrs_targeted_id
          
          ## Store user at this point...
          user.save!
          
          ## Store ID number of user object in session for normal things
          controller.session[:user_id] = user.id
          
          return true

        end
        
        ## Application authorisation setup
        def application_authorisation_setup(controller)
          
          ## Placeholder for user specified subclass/mixin
          # ...
          
          return true

        end
        
        ## Tidy up session, simple updates
        def complete_session_update(controller)
          
          ## 
          
          return true

        end      
      end
    end
  end
end