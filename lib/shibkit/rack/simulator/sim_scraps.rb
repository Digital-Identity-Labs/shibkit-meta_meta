
           
=================================
             
              ## Where do we send users to after they authenticate with IDP?
               destination = request.params['destination'] || '/'
             
             log_debug("(IDP) New user authentication requested")
             
                     
                       
             
             ## Get our user information using the param
             user_details = users[user_id.to_s]
           
             ## Check user info is acceptable
             unless user_details_ok?(user_details)
             
               log_debug("(IDP) User authentication failed - requested user not found")
             
               ## User was requested but no user details were found
               message = "User with ID '#{user_id}' could not be found!"
               http_status_code = 401
             
               return user_chooser_action(env, { :message => message, :code => code })
             
             end
           
             ## 'Authenticate', create sim IDP/SP session
             set_session(env, user_details)

             ## Clean up
             tidy_request(env)

             log_debug("(IDP) User authentication succeeded.")

             ## Redirect back to original URL
             return [ 302, {'Location'=> destination }, [] ]

           else
             
             ## Has not specified a user. So, already got a shibshim session? (shared by fake IDP and fake SP)
             if existing_idp_session?(env) and @sso

               log_debug("(IDP) User already authenticated. Redirecting back to application")

               return [ 302, {'Location'=> destination }, [] ]

             end
             
             ## Not specified a user and not got an existing session, so ask user to 'authenticate'
             log_debug("(IDP) Not already authenticated. Storing destination and showing Chooser page.")

             ## Tidy up
             tidy_request(env)
           
             ## Show the chooser page    
             return user_chooser_action(env)
        
           end
       
         ## Request is for the fake IDP's logout URL
         when sim_idp_logout_path
         
           ## Kill session
           reset_sessions(env) 
         
           log_debug("(IDP) Reset session, redirecting to IDP login page")
         
           ## Redirect to IDP login (or wayf)
           return [ 302, {'Location'=> sim_idp_login_path }, [] ]
       
         ## Request is for the fake WAYF
         when sim_wayf_path
         
           ## Specified an IDP?

         
           ## Redirect to IDP with Org type in session or something

           
           ## Not specified an IDP

         
           ## Show WAYF page

       
         ## Gateway URL? Could cover whole application or just part
         when sim_sp_path_regex 

           ## Has user already authenticated with the SP? If so we can simulate SP header injection
           if existing_sp_session? env
             
             ## TODO: SP sessions should expire
             
             log_debug("(SP)  Already authenticated with IDP and SP so injecting headers and calling application")
           
             ## Get our user information using the param
             sp_user_id = sim_sp_session(env)[:user_id]
             user_details = users[sp_user_id.to_s]
           
             ## Inject headers
             inject_sp_headers(env, user_details)
           
             ## Pass control up to higher Rack middleware and application
             return @app.call(env)
           
           end
           
           ## If the user has IDP session but not SP, we need to authenticate them at SP # TODO: possibly make this DRYer, or leave clearer?
           if existing_idp_session? env
             
             ## TODO: IDP sessions should expire
             
             log_debug("(SP)  Already authenticated with IDP but not SP, so authenticating with SP now.")
           
             ## Mark this user as authenticated with SP, so we can detect changed users, etc
             idp_user_id = sim_idp_session(env)[:user_id]
             sp_user_id = idp_user_id
             sim_sp_session(env)[:user_id] = sp_user_id
             
             ## Get user details
             user_details = users[sp_user_id.to_s]
             
             ## Inject headers
             inject_sp_headers(env, user_details)
             
             ## Pass control up to higher Rack middleware and application
             return @app.call(env)
             
           end
           
           ## If the user has neither an SP session or IDP session then they need one!
           log_debug("(SP)  No suitable IDP/SP sessions found, so redirecting to IDP to authenticate")
           
           ## Tidy up session to make sure we start from nothing (may have inconsistent, mismatched SP & IDP user ids)
           reset_sessions(env)
           
           ## Store original destination URL
           destination = ::Rack::Utils.escape(request.url)

           ## Redirect to fake IDP URL (or wayf, later)
           return [ 302, {'Location'=> "#{sim_idp_login_path}?destination=#{destination}" }, [] ]

         when sim_sp_session_path
           
           log_debug("(SP) Showing SP session status page")
         
           return sp_session_action(env, stats)
           
         ## If not a special or authenticated URL
         else
        
          ## Behave differently if in gateway mode? TODO
          log_debug("(SP)  URL not behind the SP, so just calling application")
        
          ## Pass control up to higher Rack middleware and application
          return @app.call(env)
        
         end
