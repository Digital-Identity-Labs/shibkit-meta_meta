require 'shibkit/rack/simulator/models/base'

module Shibkit
  module Rack
    class Simulator
      module Model
        class EntityService < SuperModel::Base
          
          include SuperModel::RandomID
           
          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
          
          attributes :name
          attributes :display_name
          attributes :uri
          attributes :url
          attributes :sso
          attributes :is_hidden
          #alias :hidden? :hidden
          
          
          
        end
      end
    end
  end
end
