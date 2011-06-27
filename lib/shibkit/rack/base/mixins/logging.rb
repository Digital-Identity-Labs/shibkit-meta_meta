module Shibkit
  module Rack
    class Base
      module Mixin
        module Logging

          ## Simple and switchable logger (to stdout by default)
          def log_debug(message)
  
            return unless config.debug
  
            puts [Time.new, "#{self.class.name}: ", message].join(' ')

          end
          
          



          ## Is the requested URL/path one covered by SP authentication?
          def is_path_masked?

          # ...

          return true      

          end
          
          
          
        end
      end
    end
  end
end