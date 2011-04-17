module Shibkit
  module Rack
    class Simulator
      module Mixin
        module SPActions
               
          ####################################################################
          ## SP Actions
          ##
          
          ## Controller for showing SP session status
          def sp_status_action(env, sp_session, options={}) 

            code = options[:code].to_i || 200
            
            page_body = render_page(:sp_status, render_locals)
 
            return code, Shibkit::Rack::HEADERS, [page_body.to_s]

          end          
          ## Controller for showing SP session status
          def sp_session_action(env, sp_session, options={}) 

            code = options[:code].to_i || 200
  
            ## Assemble various stats for the page
            stats = {
              :ip_address                   => env['REMOTE_ADDR'], # TODO store in session and read...
              :idp_entity_uri               => "TODO",
              :sso_protocol                 => "TODO",
              :authentication_time          => sim_sp_session(env)[:logintime],
              :authentication_context_class => "TODO",
              :authentication_context_decl  => "TODO",
              :minutes_remaining            => "TODO",
              :attributes_stats             => {
                'todo' => 'todo'
              }
            }  

            page_body = render_page(:sp_session, render_locals)
 
            return code, Shibkit::Rack::HEADERS, [page_body.to_s]

          end
          
          ## Receive authentication assertion from IDP
          def sp_sso_action(env, sp_session, options={})
            
            request = ::Rack::Request.new(env)
            
            target           = request.params['TARGET'].to_s
            encoded_response = request.params['YAMLResponse'].to_s
            
            log_debug "Encoded YAML received: #{encoded_response}"
            raise "Y/SAML Error" unless encoded_response # TODO: Better SP error handling

            sp_session.login!(encoded_response)
            
            if sp_session.logged_in?
              
              return redirect_to sp_session.destination 
              
            else
              
              raise "Failed to login" # TODO Better error handling here too
              
            end
            
          end
          
          ## Controller for handling protected pages with active session
          def sp_active_action(env, sp_session, options={})
            
            return @app.call(env)
            
          end
 
          ## Controller for handling protected pages with passive (lazy) session
          def sp_passive_action(env, sp_session, options={})
             
            return @app.call(env)
            
          end
          
          ## Controller for
          def sp_login_action(env, sp_session, options={})
            
            ## Assemble params for WAYF AuthnRequest, old style # TODO: DS protocol
            details = Hash.new
            details[:time]        = Time.new.to_i
            details[:shire]       = sp_session.sp_service.login_path
            details[:provider_id] = sp_session.sp_service.uri
            details[:target]      = sp_session.target
            
            puts "AAAAAA: "
            puts details[:target]
            
            params = ::Rack::Utils.build_query(details) 

            return redirect_to(config.sim_wayf_base_path + "/?" + params)
            
          end
          
        end
      end
    end
  end
end
