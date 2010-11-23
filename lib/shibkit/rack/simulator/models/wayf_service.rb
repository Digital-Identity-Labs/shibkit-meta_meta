require 'shibkit/rack/simulator/models/base'

module Shibkit
  module Rack
    class Simulator
      module Model
        class WAYFService < EntityService
          
          include SuperModel::RandomID
          
          
          ## Easy access to Shibkit's configuration settings
          include Shibkit::Configured
          
          
          #validates_presence_of :name, :uri

          ## Returns Directory for this organisation
          def xdirectory
            
            
            
          end
          
        end
      end
    end
  end
end