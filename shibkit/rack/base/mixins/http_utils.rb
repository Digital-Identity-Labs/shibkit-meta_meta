
module Shibkit
  module Rack
    class Base
      module Mixin
        module HTTPUtils


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
  
       end
      end
    end
  end
end
