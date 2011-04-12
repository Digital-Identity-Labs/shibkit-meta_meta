module Shibkit
  module Rack
    class Simulator
      module Mixin
        module IDPActions
          
          require 'base64'
          
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
              
              raise ::Rack::Simulator::ResourceNotHappy
              
            end
            
          end
          
          ## Controller to accept AuthnRequest requests
          def idp_authn_action(env, idp_session, options={})
    
            puts "authn action"
            code = 200
            
            request = ::Rack::Request.new(env)
            
            ## Deal with old style authnrequests
            if request.params['shire'] then

              idp_session.authn_request = 
                Shibkit::Rack::Simulator::Model::IDPAuthnRequest.new do |ar|

                   ar.shire       = request.params['shire'].to_s
                   ar.sp_time     = request.params['time'].to_i.to_s
                   ar.target      = request.params['target'].to_s
                   ar.provider_id = request.params['providerId'].to_s

                 end

            else
                 
              raise ::Rack::Simulator::NotImplemented

            end
            
            ## Redirect to the login page
            return redirect_to idp_session.idp_service.login_url
            
          end
          
          ## Controller to display login page
          def idp_form_action(env, idp_session, options={})
            
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
            
            message = options[:message]
            
            code = 200
            
            ## Are we passed suitable info?
            req = ::Rack::Request.new(env)
            username = req.params['username']
            password = req.params['password']

            ## Are we passed suitable info?
            if username.empty? or password.empty?
              
              idp_session.set_message("Please enter your username and password")
              
              return redirect_to idp_session.idp_service.login_url
            
            end
            
            ## Authenticate using the IDP's directory service
            user_id = idp_session.idp_service.directory.authenticate(username, password)
              
            ## Check that actually worked...
            unless user_id
              
              ## Explain to user what has happened
              idp_session.set_message("Failed to login. Password or username is incorrect.")
              
              ## User has not logged in. Probably doesn't exist!
              return redirect_to idp_session.idp_service.login_url
              
            end
                         
            ## Authenticate the user?
            if idp_session.login!(username) and idp_session.authn_request
              
              ## Don't bother using Metadata - cheat by grabbing the SP service info
              sp_service = Shibkit::Rack::Simulator::Model::SPSession.new(env).sp_service
              sp_sso_endpoint = sp_service.sso_url
              target = idp_session.authn_request.target
              
              encoded_response = Base64.encode64(idp_session.assertion(target).to_yaml)
              
               locals = get_locals(
                 :layout           => :idp_fwd_layout,
                 :page_title       => "Forwarding you...",
                 :sp_sso_endpoint  => sp_sso_endpoint,
                 :encoded_response => encoded_response,  
                 :target           => target
                 ) 

               page_body = render_page(:idp_redirect, locals)

               return code, Shibkit::Rack::HEADERS, [page_body.to_s]
            
            else
              
              ## Is the problem a missing authn_request or something else?
              error_message = idp_session.authn_request ? "An error has occured" :
                "No Service Provider was specified."
              
              ## Explain to user what has happened on next page view
              idp_session.set_message(error_message)
              
              ## Redirect to the login page
              return redirect_to idp_session.idp_service.login_url
              
            end
            
          end
          
          ## Controller for
          def idp_sso_action(env, options={})
            
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
