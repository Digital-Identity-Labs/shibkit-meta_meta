module Shibkit
  module Rack
    class Simulator
      module Model
        class WAYFSession
          
          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
          
          ## The optional WAYF path used in :wayf chooser mode  
          def self.path

            return config.sim_wayf_base_path

          end
          
        end
      end
    end
  end
end




