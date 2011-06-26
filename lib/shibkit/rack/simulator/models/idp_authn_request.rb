require 'shibkit/rack/simulator/models/entity_service'

module Shibkit
  module Rack
    class Simulator
      module Model
        class IDPAuthnRequest 
          
          require 'shibkit/rack/base/mixins/http_utils'
          
          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
          
          include Shibkit::Rack::Base::Mixin::HTTPUtils
          
          attr_accessor :type
          attr_accessor :protocol
          attr_accessor :shire      
          attr_accessor :target     
          attr_accessor :provider_id
          attr_accessor :sp_time
          attr_accessor :time_requested
          attr_accessor :time_expires
          
          ## New object. Takes block
          def initialize(&block) 
            
            @type           = :undefined
            @time_requested = Time.new
            @protocol       = :shibboleth
            @time_expires   = @time_requested + 60
        
            ## Execute block if passed one      
            self.instance_eval(&block) if block

          end
          
        end
      end
    end
  end
end
