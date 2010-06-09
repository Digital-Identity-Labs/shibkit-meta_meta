require 'rubygems'
require 'sax-machine'
require 'yaml'


module Shibkit
  module Metameta
   
    
    class Person
      
      include SAXMachine
      
      element "GivenName", :as => 'given_name'
      element "EmailAddress", :as => 'email_url'
      element "SurName", :as => 'surname'
      
    end
    
    class Organization
    
      include SAXMachine
      
      element "OrganizationName", :as => :name
      element "OrganizationDisplayName", :as => :display_name
      element "OrganisationURL", :as => :url
      element "OrganisationName", :value => 'xml:lang', :as => :language
    
    end
   
    class Entity
     
      include SAXMachine
     
      element "EntityDescriptor", :value => :ID, :as => :metadata_id
      element "EntityDescriptor", :value => :entityID, :as => :entity_id
      
      element "Organization", :as => 'organization', :class => Organization
      
      elements "ContactPerson", :as => 'people', :where => {:contactType => "support"}, :class => Person
      
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

data = IO.read(File.join(File.dirname(__FILE__), '..','scratch','ukfederation-metadata.xml'))
metadata = Shibkit::Metameta::Metadata.parse(data)

metadata.federations.each do |f| 
  
  puts f.federation_uri
  puts f.valid_until
  
  f.entities.each do |e|
    
    puts 
    puts e.metadata_id
    puts e.entity_id
    puts e.organization.name if e.organization
    puts e.organization.language if e.organization
     
    e.people do |p|
      
      puts p.email_url
      
    end
    
  end
  
end
  