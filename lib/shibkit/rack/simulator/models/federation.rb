require 'supermodel'

module Shibkit
  module Rack
    class Simulator
      module Model
        class Federation << SuperModel::Base
        
          include SuperModel::RandomID
        
          ## Easy access to Shibkit's configuration settings
          include Shibkit::Configured

          attributes            :name, :entity_id, :organisations, :metadata_file, :member?         
          validates_presence_of :name, :entity_id, :organisations
          
          ## Create default values
          Federation.create([{ :first_name => 'Jamie' }, { :first_name => 'Jeremy' }]) do |u|
              u.is_admin = false
            end
       
        end
      end
    end
  end
end
  