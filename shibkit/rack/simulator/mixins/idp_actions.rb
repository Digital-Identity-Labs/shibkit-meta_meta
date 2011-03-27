module Shibkit
  module Rack
    class Simulator
      module Mixin
        module IDPActions
                 
          ####################################################################
          ## IDP Actions
          ##
          
          ## Displayed if no IDP ID is provided, or if it cannot be found
          def idp_404_action(env, sim_session, options={})
          
            message = options[:message]
            code = options[:code].to_i || 404
            
            locals = get_locals(
              :idps => [],
              :page_title => "IDP Cannot Be Found"
              ) 
            
            page_body = render_page(:idp_404, locals)

            return 404, Shibkit::Rack::HEADERS, [page_body.to_s]
          
          end
          
          ## Controller for new-style IDP status
          def idp_new_status_action(env, idp_session, options={})
                   
            message = options[:message]
            code = options[:code].to_i || 404
            
            locals = get_locals(
              :idps => [],
              :layout => :plain_layout,
              :page_title => "IDP Status",
              :start_time => START_TIME.utc.xmlschema,
              :time_now   => Time.new.utc.xmlschema,
              :entity_id  => idp_session.idp_service.uri
              ) 
            
            page_body = render_page(:idp_new_system_status, locals)

            return 200, {"Content-Type" => "text/plain; charset=utf-8"}, [page_body.to_s]
            
          end  
               
          ## Controller for old "OK" status page
          def idp_old_status_action(env, idp_session, options={})
                   
            code = options[:code].to_i || 200
            
            render_locals = {:layout => :plain_layout}
            
            ## Very basic check to see if we have an IDP...
            if idp_session.idp_service
              
              page_body = render_page(:idp_old_system_status, locals)
 
              return code, {"Content-Type" => "text/plain; charset=utf-8"}, [page_body.to_s]
   
            else
              
              raise Rack::Simulator::ResourceNotHappy
              
            end
            
          end
          
          ## Controller to accept AuthnRequest requests
          def idp_authn_action(env, idp_session, options={})
          
            message = options[:message] || idp_session.get_message
            
            code = 200
            
            
            
            
           
          end
          
          ## Controller to display login page
          def idp_form_action(env, idp_session, options={})
            
            puts "Form action"
            
            message = options[:message] || idp_session.get_message
            
            code = 200
            
            locals = get_locals(
              :layout     => :layout,
              :idp        => idp_session.idp_service,
              :sp_home    => config.home_path,
              :sp_name    => config.app_name,
              :directory  => idp_session.idp_service.directory,
              :page_title => "#{idp_session.idp_service.display_name} IDP",
              :message    => message
              ) 
            
            page_body = render_page(:idp_form, locals)

            return code, Shibkit::Rack::HEADERS, [page_body.to_s]
           
          end
                   
          ## Controller for logging in to IDP
          def idp_login_action(env, idp_session, options={})
            
            puts "login action"
            
            message = options[:message]
            
            code = 200
            
            ## Are we passed suitable info?
            req = ::Rack::Request.new(env)
            username = req.params['username']
            password = req.params['password']
            dest_raw = req.params['destination']

            ## Are we passed suitable info?
            if username.empty? or password.empty?
              
              idp_session.set_message("Please enter your username and password")
              
              return redirect_to idp_session.login_path
            
            end
            
            ## Authenticate using the IDP's directory service
            user_id = idp_session.idp_service.directory.authenticate(username, password)
              
            ## Check that actually worked...
            unless user_id
              
              ## Explain to user what has happened
              idp_session.set_message("Failed to login. Password or username is incorrect.")
              
              ## User has not logged in. Probably doesn't exist!
              return redirect_to idp_session.login_path
              
            end
                         
            ## Authenticate the user?
            if idp_session.login!(username)
            
               locals = get_locals(
                 :layout => :layout,
                 :page_title => "Forwarding you...",
                 :destination => URI.unescape(dest_raw)
                 ) 

               page_body = render_page(:idp_redirect, locals)

               return code, Shibkit::Rack::HEADERS, [page_body.to_s]
            
            else
              
              ## This is odd TODO Raise an error here
              raise "EH? User #{user_id} has failed to login to IDP, but is in directory"
              return redirect_to idp_session.login_path
              
            end
            
          end
          
          ## Controller for
          def idp_sso_action(env, options={})
            
            puts "SSO action"
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, Shibkit::Rack::HEADERS, [page_body.to_s]
            
          end
          
          ## Controller for
          def idp_logout_action(env, options={})
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, Shibkit::Rack::HEADERS, [page_body.to_s]
            
          end
          
        end
      end
    end
  end
end
