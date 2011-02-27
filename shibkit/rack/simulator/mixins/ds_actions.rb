module Shibkit
  module Rack
    class Simulator
      module Mixin
        module DSActions
          

          ####################################################################
          ## WAYF Actions
          ##
          
          ## Controller for
          def wayf_action(env, wayf_session, options={})
            
            request = ::Rack::Request.new(env)
            term = request.params['term'].to_s.downcase.strip[0..40]
            idps = Shibkit::Rack::Simulator::Model::IDPService.all
            
            code = 200
              
            ## We've got a term request so respond with JSON
            unless term.empty?  
              
              results = Array.new
              
              idps.each do |idp|
              
                if idp.display_name.downcase =~ /#{term}/  
              
                  result = Hash.new
                  result['id']    = idp.id
                  result['label'] = idp.display_name
                  result['value'] = idp.display_name
                 
                  results << result
                  
                end
              
              end
              
              page_body = results.to_json
              
              puts page_body
              
              return code,
                { "Content-Type" => "application/json" },
                page_body
              
            end  
                                   
            locals = get_locals(
              :layout     => :layout,
              :javascript => :wayf,
              :wayf       => wayf_session, # TODO: should this be the service instead?
              :idps       => idps.sort! { |a,b| a.display_name.downcase <=> b.display_name.downcase },
              :page_title => "Select Your Home Organisation"
            )
            
            page_body = render_page(:wayf_smart, locals)
              
            return code, HEADERS, [page_body.to_s]
                
          end
          
         

        end
      end
    end
  end
end
