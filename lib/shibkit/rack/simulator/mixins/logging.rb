module Shibkit
  module Rack
    class Simulator
      module Mixin
        module Logging

          ## Simple and switchable logger (to stdout by default)
          def log_debug(message)
  
            return unless config.sim_debug
  
            puts [Time.new, "Shibkit-Simulator:", message].join(' ')

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