require 'shibkit/rack/simulator/models/base'

module Shibkit
  module Rack
    class Simulator
      module Model
        class WAYFService < Base
          
          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
          
          setup_storage
          
          ## Return all federations that contain IDPs
          def federations
            
            return Federation.all.collect {|f| f if !f.idps.empty?}.compact
            
          end
          
          ## Return all idps that contain users
          def idps
            
            ## TODO: this bit if bugged and bodged 
            return Shibkit::Rack::Simulator::Model::IDPService.all.collect {|i|
               i if i and
               i.directory and
               !i.directory.accounts.empty?}.compact
            
          end
          
        end
        
      end
    end
  end
end