module Shibkit
  module Rack
    class Simulator
      module Mixin
        module Actions
          
          ## Return the global stylesheet
          def stylesheet_action(env, nil_session, options={})
              
            code = 200
            page_body = asset("stylesheet.css")

            return code, {"Content-Type" => "text/css; charset=utf-8"}, [page_body.to_s]
        
          end
          
          ## Return the appropriate image for something from a path ending in /image/something
          def image_action(env, nil_session, options={})
            
            ## TODO: Needs to be a bit fancier and less SVG-hardcoded (made into another lib?)
      
            specified = options[:specified] || "alert"
            
            page_body = asset(specified + ".svg")
            
            code = 200
            
            return code, {"Content-Type" => "image/svg+xml"}, [page_body.to_s]
        
          end
          
          ## Displayed if no IDP ID is provided, or if it cannot be found
          def browser_404_action(env, sim_session, options={})
          
            message = options[:message]
            
            code = 404
            
            locals = get_locals(
              :layout => :browser_layout,
              :idps => [],
              :code => code,
              :requested => env['REQUEST_URI'],
              :page_title => "Simulated Server Not Found"
              ) 
            
            page_body = render_page(:browser_404, locals)

            return code, CONTENT_TYPE, [page_body.to_s]
          
          end
          
          ## Displayed if no IDP ID is provided, or if it cannot be found
          def idp_404_action(env, sim_session, options={})
          
            message = options[:message]
            code = options[:code].to_i || 404
            
            locals = get_locals(
              :idps => [],
              :page_title => "IDP Cannot Be Found"
              ) 
            
            page_body = render_page(:idp_404, locals)

            return 404, CONTENT_TYPE, [page_body.to_s]
          
          end
          
          ## Controller for
          def idp_status_action(env, options={})
                   
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]
            
          end
          
          ## Controller for
          def idp_session_action(env, options={})
            
            
            
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]
            
          end
          
          ## Controller for
          def idp_login_action(env, options={})
            
            
            
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]
            
          end
          
          ## Controller for
          def idp_sso_action(env, options={})
            
            
            
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]
            
          end
          
          ## Controller for user presentation page
          def idp_simple_chooser_action(env, options={}) 

            message = options[:message] 
            code    = options[:code].to_i || 200

            render_locals = { :organisations => organisations, :users => users,
                                :message => message, :idp_path => sim_idp_login_path }
            page_body = render_page(:user_chooser, render_locals)

            return code, CONTENT_TYPE, [page_body.to_s]

          end
          
          ## Controller for
          def idp_logout_action(env, options={})
            
            
            
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]
            
          end
          
          ## Controller for
          def wayf_action(env, options={})
            
            
            
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]
            
          end
          
          ## Controller for showing SP session status
          def sp_session_action(env, options={}) 

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

            page_body = render_page(:user_chooser, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]

          end
          
          
          
          ## Controller for
          def sp_protected_page_action(env, options={})
            
            
            
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]
            
          end
          
          
          ## Controller for
          def sp_login_action(env, options={})
            
            
            
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]
            
          end


          ## Error page for unrecoverable situations
          def fatal_error_action(env, oops)

            log_debug("****  Fatal error: #{oops}")

            unless ENV['RACK_ENV'] == :production or ENV['RAILS_ENV'] == :production

              puts "\nBacktrace is:\n#{oops.backtrace.to_yaml}\n"

            end

            render_locals = { :message => oops.to_s }
            page_body = render_page(:fatal_error, render_locals)

            return 500, CONTENT_TYPE, [page_body.to_s]

          end

          def get_locals(*specified_locals)
            
            return {
              :page_title   => "Shibkit",
              :code         => 200,
              :content_type => CONTENT_TYPE
            }.merge *specified_locals
            
          end

        end
      end
    end
  end
end
