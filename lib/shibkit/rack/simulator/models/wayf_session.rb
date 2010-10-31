module Shibkit
  module Rack
    class Simulator
      module Model
        class WAYFSession
          
          ## Easy access to Shibkit's configuration settings
          include Shibkit::Configured
          
          ## The optional WAYF path used in :wayf chooser mode  
          def sim_wayf_path

            return config.sim_wayf_path

          end
          
        end
      end
    end
  end
end




