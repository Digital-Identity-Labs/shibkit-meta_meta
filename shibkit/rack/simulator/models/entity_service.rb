require 'shibkit/rack/simulator/models/base'

module Shibkit
  module Rack
    class Simulator
      module Model
        class EntityService < Base
           
          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
          
          setup_storage
          
          attr_accessor :name
          attr_accessor :display_name
          attr_accessor :uri
          attr_accessor :url
          attr_accessor :sso
          attr_accessor :hidden
          alias :hidden? :hidden
          
        
          private
          
          def sim_url_style
            
            return :numeric
            
          end
          
          def service_type_base_path
            
            return "/undefined_service/"
            
          end
          
        end
        
      end
    end
  end
end
