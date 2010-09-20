## Some 3rd-party libraries
require 'deep_merge'

## Custom exception classes
require 'shibkit/exceptions'

## Shibkit Configuration singleton
require 'shibkit/config'

## Shibkit utility classes
require 'shibkit/data_tools'

## Essential 
require 'shibkit/sp_assertion'

## Rack it up
if defined?(Rack)

  require "shibkit/rack/shib_sim"
  require "shibkit/rack/shib_shim"

end

## Rails libraries
if defined?(Rails)

  require  "shibkit/rails/core_controller_mixin"
  require  "shibkit/rails/seed_data_mixin"

end

## Mongoid Extensions
if defined?(Mongoid)
  
  require "mongoid_userstamps"
  
end


