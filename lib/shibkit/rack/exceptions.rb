
module Shibkit
  
  module Rack
  
    ## Exception class used here to limit rescued errors to this middleware only
    class RuntimeError < Shibkit::RackMiddlewareError 

    end
  
    ## For triggering fake browser 404s
    class ResourceNotFound < Shibkit::RackMiddlewareError 

    end
      
    ## For triggering fake IDP 500s 
    class ResourceNotHappy < Shibkit::RackMiddlewareError 

    end
      
  end
end
