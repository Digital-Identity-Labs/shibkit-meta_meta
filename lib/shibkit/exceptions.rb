module Shibkit
  
  class ShibkitError < StandardError
  

  end
  
  ## List a few other exception classes
  exception_classes = %w"
    ConfigurationError
    SPIntegrationError
    RackMiddlewareError
  "
  
  ## Create the additional exception classes
  exception_classes.each { |e| const_set(e, Class.new(ShibkitError)) }
  
end