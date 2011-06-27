module Shibkit
  module Rack
    class Simulator
      module Mixin
        module BrowserActions
        
          ####################################################################
          ## 'Browser' Actions
          ##
          
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

            return code, Shibkit::Rack::HEADERS, [page_body.to_s]
          
          end
 
        end
      end
    end
  end
end
