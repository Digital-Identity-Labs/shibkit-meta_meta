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
  
            "A valid session was not found."

            page_body = render_page(:sp_status, render_locals)
 
            return code, HEADERS, [page_body.to_s]

          end          
          ## Controller for showing SP session status
          def sp_session_action(env, sp_session, options={}) 

            code = options[:code].to_i || 200
  
            "A valid session was not found."
  
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
 
            return code, HEADERS, [page_body.to_s]

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
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, HEADERS, [page_body.to_s]
            
          end
          
        end
      end
    end
  end
end
