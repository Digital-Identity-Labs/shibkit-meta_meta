module Shibkit
  module Rack
    class Demo
      module Mixin
        module Actions
          
          
          ####################################################################
          ## Misc Actions
          ##
              
          ## Redirect browser to a new Simulator URL
          def redirect_to(path)
            
            url = path
            
            return 302, {'Location'=> url }, []
            
          end          
          
          ####################################################################
          ## Resource Actions
          ##
          
          ## Return the global stylesheet
          def stylesheet_action(env, nil_session, options={})
              
            code = 200
            page_body = asset("stylesheet.css")

            return code, {"Content-Type" => "text/css; charset=utf-8"}, [page_body.to_s]
        
          end
          
          ## Return the appropriate image for something from a path ending in /image/something
          def javascript_action(env, nil_session, options={})
            
            ## TODO: Needs to be a bit fancier and less SVG-hardcoded (made into another lib?)
      
            specified = options[:specified] || "alert"
            
            page_body = asset(specified + ".js")
            
            code = 200
            
            return code, {"Content-Type" => "text/javascript"}, [page_body.to_s]
        
          end
          
          ## Return the appropriate image for something from a path ending in /image/something
          def image_action(env, nil_session, options={})
          
            specified = options[:specified] || "placeholder"
            
            extension    = ".svg"
            content_type = "image/svg+xml"
            page_body    = ""
            
            formats = [
              [".svg", "image/svg+xml"],
              [".png", "image/png"]
            ]
            
            ## Try each format in order (an ordered hash in 1.8 would have been nice)
            formats.each do |ext_and_mime|
              
              ext, mime = ext_and_mime
              
              page_body    = asset(specified + ext)
              content_type = mime
              
              break unless page_body.to_s.empty? 
              
            end
            
            return browser_404_action(env, nil, {}) unless page_body
            
            return 200, {"Content-Type" => content_type}, [page_body.to_s]
        
          end
          
          actively_protected_demo_page_action
          passively_protected_demo_page_action
          

          ####################################################################
          ## Halt/Error Actions
          ##
          
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
          
          ###########################
          
          def get_locals(*specified_locals)
            
            return {
              :page_title   => "Shibkit",
              :code         => 200,
              :assets_base  => config.sim_asset_base_path,
              :content_type => CONTENT_TYPE
            }.merge *specified_locals
            
          end

        end
      end
    end
  end
end
