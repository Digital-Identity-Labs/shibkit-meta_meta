require 'rubygems'
require 'happymapper'
require 'yaml'


module Shibkit
  module MetaMeta
   
    
    class Person
      
      include HappyMapper
      
      tag "ContactPerson"
      
      element :given_name, String, :tag => "GivenName"
      element :email_url,  String, :tag => "EmailAddress"
      element :surname,    String, :tag => "SurName"
      attribute :type,     String, :tag => "contactType"
      
    end
    
    class Organization
    
      include HappyMapper
      
      tag "Organization"
      
      element :name,         String, :tag => "OrganizationName"
      element :display_name, String, :tag => "OrganizationDisplayName"
      element :url,          String, :tag => "OrganizationURL"
    
    end
      
    class Extensions
      
      include HappyMapper
      
      tag "Extensions"
      
       has_one :accountable, Boolean, :tag => "AccountableUsers", :namespace => "http://ukfederation.org.uk/2006/11/label", :single => true
       element :ukfm,   Boolean, :tag => "UKFederationMember", :namespace => "http://ukfederation.org.uk/2006/11/label"
       element :athens, Boolean, :tag => "AthensPUIDAuthority", :namespace => "http://ukfederation.org.uk/2006/11/label"
       element :scope,  String,  :tag => "Scope", :namespace => "urn:mace:shibboleth:metadata:1.0", :deep => true
      
    end
    
    class IDP
      
      include HappyMapper
      
      tag "IDPSSODescriptor"
    
      element :ext, String, :tag => "Extensions", :raw => true
      
    end
    
    class Entity
     
      include HappyMapper
     
      tag "EntityDescriptor"
     
      attribute :federation_id, String,       :tag => "ID"
      attribute :entity_id,     String,       :tag => "entityID"
           
      has_one   :organisation,  Organization, :tag => "Organization"
      has_one   :extensions,    Extensions,   :tag => "Extensions"
      has_many  :people,        Person,       :tag => "ContactPerson"
      has_one   :idp, IDP, :tag => "IDPSSODescriptor"
      
    end
    
    class Federation
     
      include HappyMapper
      
      tag "EntitiesDescriptor"
      
      attribute :federation_uri, String, :tag => "Name", :namespace => "urn:oasis:names:tc:SAML:2.0:metadata"
      attribute :valid_until,    String, :tag => "validUntil", :namespace => "urn:oasis:names:tc:SAML:2.0:metadata"
      has_many  :entities,       Entity, :tag => "EntityDescriptor"
      
    end
    
  end

end

data = IO.read('/tmp/ukfederation-metadata.xml')
#data.gsub!('></UKFederationMember>','>true</UKFederationMember>')
#data.gsub!('></UKFederationMember>','>true</UKFederationMember>')
#data.gsub!('></UKFederationMember>','>true</UKFederationMember>')

fed = Shibkit::MetaMeta::Federation.parse(data)
puts fed.to_yaml

#metadata.federations.each do |f| 
  
#  puts f.federation_uri
#  puts f.valid_until
  
#  f.entities.each do |e|
    
#    puts 
#    puts e.metadata_id
#    puts e.entity_id
#    puts e.organization.name if e.organization
#    puts e.organization.language if e.organization
     
#    e.people do |p|
      
#      puts p.email_url
      
#    end
    
#  end
  
#end
  