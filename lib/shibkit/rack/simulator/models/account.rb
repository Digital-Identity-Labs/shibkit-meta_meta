require 'shibkit/rack/simulator/models/base'

module Shibkit
  module Rack
    class Simulator
      module Model
        class Account < Base
       
          ## Easy access to Shibkit's configuration settings
          include Shibkit::Configured
          
          
          setup_storage
          
          ## 
          attr_accessor :principal
          attr_accessor :expires
          attr_accessor :attributes
          attr_accessor :type
                  
          
          def set_defaults
            
            @attributes = Hash.new
            @type       = :ldap
            @principal  = nil
            
          end
   
   
   
        end
      end
    end
  end
end
