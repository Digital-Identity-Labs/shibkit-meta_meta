module Shibkit
  module Rack
    class Demo
      module Mixin
        module Actions
          
          DEMO_PAGES = {
            'welcome' => :welcome,
            'content' => :content,
            'account' => :account
          }
          DEMO_PAGES.default = :welcome
          
          DEMO_PAGE_REGEX = /(\w+)\/(\w+)$/
          
          ####################################################################
          ## Demo page display
          ##
          
          ## Returns the appropriate template
          def demo_page_action(env, nil_session, options={})
            
            path = ::Rack::Request.new(env).path
            
            locals = get_locals(
              :layout => :demo_layout,
              :idps => [],
              :code => 200,
              :page_title => "Demo eResource"
              ) 
            
            ## Extract requested page from URL (yeah, I should be using better routing than this...)
            bits = DEMO_PAGE_REGEX.match(path)

            requested_page = bits ? bits[2] : 'welcome'
            
            puts requested_page
            
            demo_page = DEMO_PAGES[requested_page]            
            page_body = render_page(demo_page, locals)

            return 200, CONTENT_TYPE, [page_body.to_s]    
        
          end
          
          #actively_protected_demo_page_action
          #passively_protected_demo_page_action
          


        end
      end
    end
  end
end
