module Shibkit
  module Rack
    class Debug
      module Mixin
        module Actions
          
          ####################################################################
          ## Debug page display
          ##
          
          ##
          ## Returns the appropriate template
          def debug_page_action(env, nil_session, options={})
            
            locals = get_locals(
              :layout => :debug_layout,
              :idps => [],
              :code => 200,
              :page_title => "Shibkit State"
              ) 
              
            page_body = render_page(:dump_page, locals)

            return 200, Shibkit::Rack::HEADERS, [page_body.to_s]    
        
          end
        end
      end
    end
  end
end
