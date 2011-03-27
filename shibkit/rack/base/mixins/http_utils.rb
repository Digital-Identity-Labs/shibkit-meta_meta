
module Shibkit
  module Rack
    class Base
      module Mixin
        module HTTPUtils

          private
          
          ## Build a full URL (will be various options to change this later TODO)
          def build_sim_url(*path_fragments)
            
            ## Assuming :numeric type for now
            
            scheme   = "http://"
            hostname = "localhost"
            port     = 3000.to_s
            
            full_path = glue_paths(service_type_base_path, id.to_s, *path_fragments)
            
            url = scheme + hostname + ":" + port + full_path
             
            return url
            
          end
          
          ##
          ## Glue together path fragments
          def glue_paths(*fragments)
  
            ## Use File to glue stuff, but then
            path = File.join fragments
  
            ## ...work around this dirty trick's snag: Windows
            path.gsub('\\', "/" ) unless File::SEPARATOR == '/'
  
            ## Memoisation here?
            # ...
  
            return path
  
          end
  
          ## Reformat the base path for IDP URLs to capture info in URL
          def base_path_regex(base_path)

            normalised_path = base_path.gsub(/\/$/, '')
            return Regexp.new(normalised_path)

          end

          ## 
          ## Memoise relatively expensive regex creation and escaping
          def regexify(path)

            @recache ||= Hash.new

            unless @recache[path]

              @recache[path] ||= /#{Regexp.escape(path)}/

            end

            return @recache[path]

          end

          ## 
          def component_name

            return self.class.to_s.gsub('::', ':').split(':').reverse[0].downcase

          end
          
          
          
       end
      end
    end
  end
end
