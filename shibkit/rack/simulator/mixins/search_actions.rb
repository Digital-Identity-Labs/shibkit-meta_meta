module Shibkit
  module Rack
    class Simulator
      module Mixin
        module SearchActions
          
          ####################################################################
          ## Search Actions
          ##
          
          ## Controller for mockup of search engine (OK, WHY? For direct links to home and subpages) 
          def search_action(env, sp_session, options={})
                    
            code = 200

            locals = get_locals(
              :layout     => :layout,
              :javascript => :ggl,
              :sp         => sp_session, # TODO: should this be the service instead?
              :page_title => "Shibkitoogle"
              ) 

            page_body = render_page(:ggl, locals)

            return code, HEADERS, [page_body.to_s]
                      
          end
      
        end
      end
    end
  end
end
