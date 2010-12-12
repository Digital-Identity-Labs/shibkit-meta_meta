
module Shibkit
  
  module Rack
  
    class Simulator


      ## Exception class used here to limit rescued errors to this middleware only
      class RuntimeError < Shibkit::RackMiddlewareError 

      end
  
      ## For triggering 404s
      class ResourceNotFound < Shibkit::RackMiddlewareError 

      end
      
    end
  end
end