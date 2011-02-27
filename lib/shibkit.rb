## Some 3rd-party libraries
require 'deep_merge'

## Custom exception classes
require 'shibkit/exceptions'

## Shibkit Configuration singleton
require 'shibkit/config'

## Shibkit utility classes
require 'shibkit/data_tools'
require 'shibkit/metameta'

## Essential 
require 'shibkit/sp_assertion'

## Rack it up
if defined?(Rack)
  
  require "shibkit/rack/assets"
  require "shibkit/rack/simulator"
  require "shibkit/rack/shim"
  require "shibkit/rack/debug"
  require "shibkit/rack/demo"

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


