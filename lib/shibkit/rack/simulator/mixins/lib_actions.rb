module Shibkit
  module Rack
    class Simulator
      module Mixin
        module LibActions
                 
          ####################################################################
          ## Library Actions
          ##
          
          ## Controller for simple Library page (done differently. TODO: Change?)
          def library_action(env)
            
            begin
              
              request = ::Rack::Request.new(env)
              
              ## Extract the IDs
              path = request.path.gsub(config.sim_lib_base_path, "")
              idp_id = path.split('/')[0] || nil

              ## Clean things up a bit.
              idp_id  = idp_id.to_i.to_s
              
              ## Get the IDP session object
              idp = Model::IDPService.find(idp_id) 

              ## Missing Dir id? Show a 404 sort of thing
              unless idp_id and idp

                raise Shibkit::Rack::ResourceNotFound, "Unable to find Library with suitable Shibboleth IDP (#{idp_id})"

              end

            rescue Shibkit::Rack::ResourceNotFound => oops

                return browser_404_action(env, nil, {})

            end
          
            code = 200

            locals = get_locals(
              :layout     => :layout,
              :idp        => idp,
              :page_title => "Online Resources at #{idp.display_name} Library"
              ) 

            page_body = render_page(:library, locals)

            return code, Shibkit::Rack::HEADERS, [page_body.to_s]
                      
          end
          
        end
      end
    end
  end
end
