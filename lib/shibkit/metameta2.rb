require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'yaml'


module Shibkit
  class MetaMeta
    
    class Federation
      
      attr_accessor :name, :metadata_id, :federation_uri, :valid_until, :entities  
      
    end

    class Organisation
      
      attr_accessor :name, :display_name, :url
      
    end
    
    class Entity
      
      attr_accessor :federation_uri, :metadata_id, :entity_uri, :accountable, :ukfm,
                    :athens, :scopes, :organisation, :extensions,
                    :accountable, :support_contact, :technical_contact, :idp, :sp
                    
      alias :entity_id :entity_uri
      alias :idp? :idp 
      alias :sp?  :sp
      alias :ukfm? :ukfm
      alias :accountable? :accountable
      alias :athens? :athens
      alias :organization :organisation
      
    end

    class Contact
      
      attr_accessor :givenname, :surname, :email_url, :category   
      
      def display_name
      
        return [givenname, surname].join(' ')
      
      end
      
    end

    def MetaMeta.parse_metadata_file(federation_name, metadata_filename)
      
      metadata_text = IO.read(metadata_filename)
      
      return MetaMeta.parse_metadata(federation_name, metadata_text)
      
    end

    def MetaMeta.parse_metadata(federation_name, metadata_text)
      
      ## Parse the entire file as an XML document
      doc = Nokogiri::XML.parse(metadata_text) do |config|
        config.strict.noent.dtdvalid
      end
      
      ## Find the Federation level metadata xml, if present
      federation = Federation.new
      fx  = doc.root
      
      ## Add exotic namespaces to make sure we can deal with all metadata # TODO
      fx.add_namespace_definition('ukfedlabel','http://ukfederation.org.uk/2006/11/label')
      fx.add_namespace_definition('elab','http://eduserv.org.uk/labels')
      
      ## Extract basic 'federation' information 
      federation.name           = federation_name
      federation.metadata_id    = fx['ID']
      federation.federation_uri = fx['Name']
      federation.valid_until    = fx['validUntil']
      federation.entities       = Array.new
      
      ## Process XML chunk for each entity in turn
      fx.xpath("//xmlns:EntityDescriptor").each do |ex|
        
        entity = Entity.new
        entity.federation_uri = federation.federation_uri
        entity.entity_uri     = ex['entityID']
        entity.metadata_id    = ex['ID']
      
        entity.accountable = ex.xpath('xmlns:Extensions/ukfedlabel:AccountableUsers').size   > 0 ? true : false
        entity.ukfm        = ex.xpath('xmlns:Extensions/ukfedlabel:UKFederationMember').size > 0 ? true : false
        entity.athens      = ex.xpath('xmlns:Extensions/elab:AthensPUIDAuthority').size      > 0 ? true : false
        entity.scopes      = ex.xpath('xmlns:IDPSSODescriptor/xmlns:Extensions/shibmd:Scope').collect { |x| x.text }
        entity.idp         = ex.xpath('xmlns:IDPSSODescriptor') ? true : false
        entity.sp          = ex.xpath('xmlns:SPSSODescriptor')  ? true : false
        
        entity.support_contact   = extract_contact(ex, 'support') 
        entity.technical_contact = extract_contact(ex, 'technical')
        
        ox = ex.xpath('xmlns:Organization[1]')
        org = Organisation.new
        org.name         = ox.xpath('xmlns:OrganizationName[1]')[0].content
        org.display_name = ox.xpath('xmlns:OrganizationDisplayName[1]')[0].content
        org.url          = ox.xpath('xmlns:OrganizationURL[1]')[0].content
        
        entity.organisation = org
    
        federation.entities << entity
        
      end
       
      return federation
      
    end
    
    private
    
    def MetaMeta.extract_contact(entity_xml, type)
    
      sx = entity_xml.xpath("xmlns:ContactPerson[@contactType='#{type.to_s}'][1]")[0]
      
      contact = Contact.new
      
      if sx and sx.content
        contact.givenname = sx.xpath('xmlns:GivenName[1]')[0].content    if sx.xpath('xmlns:GivenName[1]')[0]
        contact.surname   = sx.xpath('xmlns:SurName[1]')[0].content      if sx.xpath('xmlns:SurName[1]')[0]
        contact.email_url = sx.xpath('xmlns:EmailAddress[1]')[0].content if sx.xpath('xmlns:EmailAddress[1]')[0]
        contact.category  = sx['contactType']
      end
    
      return contact
    
    end
    
  end
end
