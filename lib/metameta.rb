require 'rubygems'
require 'sax-machine'
require 'yaml'


module Shibkit
  module Metadata
   
    class Entity
     
      include SAXMachine
     
      element "EntityDescriptor", :value => :ID, :as => :metadata_id
      element "EntityDescriptor", :value => :entityID, :as => :entity_id
    
    end
    
    class Federation
     
      include SAXMachine
      
      element "EntitiesDescriptor", :value => :name, :as => :federation_uri
      element "EntitiesDescriptor", :value => :validuntil, :as => :valid_until
     
      elements "EntityDescriptor", :as => :entities, :class => Entity
     
      elements "ds:SignatureValue", :as => 'sigs'
     
    end
    
    class Metadata
      
      include SAXMachine
      elements "EntitiesDescriptor", :as => :federations, :class => Federation
      
    end
    
  end

end

data = IO.read('metadata.xml')
metadata = Shibkit::Metadata::Metadata.parse(data)

metadata.federations.each do |f| 
  
  puts f.federation_uri
  puts f.valid_until
  
  f.entities.each do |e|
    
    puts 
    puts e.metadata_id
    puts e.entity_id
    
    
  end
  
end
  