module Shibkit
  module Rack
    class Simulator
      module Mixin
        module DirActions
              
                       
          ####################################################################
          ## Directory Actions
          ##
          
          ## Controller for directory Search/List 
          def directory_list_action(env, directory, options={})
            
            #message = options[:message] || idp_session.get_message

             code = 200

             locals = get_locals(
               :layout     => :layout,
               :directory  => directory,
               :page_title => directory.display_name,
               :message    => "message"
               ) 

             page_body = render_page(:directory_list, locals)

             return code, Shibkit::Rack::HEADERS, [page_body.to_s]
                
          end

          ## Controller for directory entry 
          def directory_item_action(env, directory, options={})
            
            #message = options[:message] || idp_session.get_message

             code = 200

             locals = get_locals(
               :layout     => :layout,
               :directory  => directory,
               :user       => options[:account],
               :page_title => directory.display_name,
               :message    => "message"
               ) 

             page_body = render_page(:directory_item, locals)

             return code, Shibkit::Rack::HEADERS, [page_body.to_s]
                
          end
          
        end
      end
    end
  end
end
