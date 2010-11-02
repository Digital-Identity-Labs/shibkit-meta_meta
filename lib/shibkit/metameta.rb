## This file is part of Shibkit
##
## Author::    Pete Birkinshaw  (mailto:pete@binary-ape.org)
## Copyright:: Copyright (c) 2010 Pete Birkinshaw & Digital Identity Ltd
## License::   MIT (Please read the LICENSE file shipped with this code)

require 'rubygems'
require 'nokogiri'
require 'yaml'
require 'open-uri'
#require 'typhoeus'

require 'shibkit'

module Shibkit
  
  ## Simple library to parse Shibboleth metadata files into Ruby objects
  class MetaMeta
    
    class Source
      
      attr_accessor :name
      attr_accessor :file
      attr_accessor :refresh
      attr_accessor :cache
      
      ## New default object
      def initialize(&block)
      
        @name    = "Unknown"
        @file    = nil
        @refresh = 0
        @cache   = true
      
        self.instance_eval(&block) if block
      
      end
      
      ## Return raw source string from the file
      def content
        
        
        
      end
      
      ## Source is reachable, valid filename/URI, etc. Does not check content
      def ok?
        
        
      end
      
    end
        
    ## Class to represent a Shibboleth Federation or collection of local metadata
    ## 
    class Federation
      
      ## The human-readable display name of the Federation or collection of metadata
      attr_accessor :display_name
      
      ## The unique ID of the federation document (probably time/version based)
      attr_accessor :metadata_id
      
      ## The URI name of the federation (may be missing for local collections)
      attr_accessor :federation_uri
      
      ## Expiry date of the published metadata file
      attr_accessor :valid_until
      
      ## Array of entities within the federation or metadata collection
      attr_accessor :entities  
      
      ## Time the Federation metadata was parsed
      attr_accessor :read_at
      
    end
    
    ## Class to represent the metadata of the organisation owning a Shibboleth entity
    class Organisation
      
      ## The name identifier for the organisation
      attr_accessor :name
      
      ## The human-readable display name for the organisation
      attr_accessor :display_name
      
      ## The homepage URL for the organisation
      attr_accessor :url
      
    end
    
    ## Class to represent the metadata of a Shibboleth IDP or SP 
    class Entity
      
      ## The URI of the entity's parent federation
      attr_accessor :federation_uri
      
      ## The ID of the entity with the metadata file (not globally unique)
      attr_accessor :metadata_id
      
      ## The URI of the entity
      attr_accessor :entity_uri
      
      ## Is the entity accountable?
      attr_accessor :accountable
      
      ## Is the entity part of the UK Access Management Federation?
      attr_accessor :ukfm
      
      ## Is the entity using Athens?
      attr_accessor :athens
      
      ## Scopes used by the entity (if an IDP)
      attr_accessor :scopes
      
      ## Organisation object for the owner of the entity 
      attr_accessor :organisation
      
      ## Contact object containing user support contact details
      attr_accessor :support_contact
      
      ## Contact object containing technical contact details
      attr_accessor :technical_contact
      
      ## Is the entity an IDP?
      attr_accessor :idp
      
      ## Is the entity an SP?
      attr_accessor :sp
                    
                    
      alias :entity_id :entity_uri
      alias :idp? :idp 
      alias :sp?  :sp
      alias :ukfm? :ukfm
      alias :accountable? :accountable
      alias :athens? :athens
      alias :organization :organisation
      
    end
    
    ## Class to represent technical or suppor contact details for an entity
    class Contact
      
      ## The given name of the contact (often the entire name is here)
      attr_accessor :givenname
      
      ## The surname of the contact
      attr_accessor :surname
      
      ## The email address of the contact formatted as a mailto: URL
      attr_accessor :email_url
      
      ## The category of the contact (support or technical)
      attr_accessor :category   
      
      ## Usually both the surname and givenname of the contact
      def display_name
      
        return [givenname, surname].join(' ')
      
      end
      
    end
    
    ##
    ## The MetaMeta object itself
    ##
    
    ## Easy access to Shibkit's configuration settings
    include Shibkit::Configured
    
    attr_accessor :sources
    attr_accessor :federations
        
    ## New default object
    def initialize(&block)
    
      @sources     = Array.new
      @federations = Array.new
      
      self.instance_eval(&block) if block
    
    end
    
    ## Convenience method to add a source
    def add_source(name, file, refresh=360, cache=true)
    
      self.sources << Source.new do |s|
        
        s.name    = name
        s.file    = file
        s.refresh = refresh
        s.cache   = cache
        
      end
    
    end
    
    ## Downloads and reprocesses metadata files  
    def refresh(force=false)
      
      @sources.each do |source|
      
        @federations << MetaMeta.parse_metadata_file(source.name, source.file)
      
      end
      
    end 
    
    ## Loads federation metadata contents 
    def load_cache_file(file_or_url)
        
        @federations = YAML::load(File.open(file_or_url))
        
    end
    
    ## Save entity data into a YAML file. 
    def save_cache_file(file)
        
        ## Will *not* overwrite the example/default file in gem! TODO: this code is awful.
        gem_data_path = "#{::File.dirname(__FILE__)}/data"
        if file.include? gem_data_path 
          raise "Attempt to overwrite gem's default metadata cache! Please specify your own file to save cache in"
        end
        
        ## Write the YAML to disk
        File.open(file, 'w') do |out|
           YAML.dump(@federations, out)
         end
        
    end    
    
    ## Parses the specified metadata xml file and returns a federation object
    def MetaMeta.parse_metadata_file(federation_name, metadata_filename)
      
      metadata_text = IO.read(metadata_filename)
      
      return MetaMeta.parse_metadata(federation_name, metadata_text)
      
    end
    
    ## Parses a string containing metadata XML and returns a federation object
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
      federation.display_name   = federation_name
      federation.metadata_id    = fx['ID']
      federation.federation_uri = fx['Name']
      federation.valid_until    = fx['validUntil']
      federation.entities       = Array.new
      
      ## Process XML chunk for each entity in turn
      fx.xpath("//xmlns:EntityDescriptor").each do |ex|
        
        ## Basics for the entity
        entity = Entity.new
        entity.federation_uri = federation.federation_uri
        entity.entity_uri     = ex['entityID']
        entity.metadata_id    = ex['ID']
      
        ## Then boolean flags for common/useful info 
        entity.accountable = ex.xpath('xmlns:Extensions/ukfedlabel:AccountableUsers').size   > 0 ? true : false
        entity.ukfm        = ex.xpath('xmlns:Extensions/ukfedlabel:UKFederationMember').size > 0 ? true : false
        entity.athens      = ex.xpath('xmlns:Extensions/elab:AthensPUIDAuthority').size      > 0 ? true : false
        entity.scopes      = ex.xpath('xmlns:IDPSSODescriptor/xmlns:Extensions/shibmd:Scope').collect { |x| x.text }
        entity.idp         = ex.xpath('xmlns:IDPSSODescriptor') ? true : false
        entity.sp          = ex.xpath('xmlns:SPSSODescriptor')  ? true : false
        
        ## Include Contact objects
        entity.support_contact   = extract_contact(ex, 'support') 
        entity.technical_contact = extract_contact(ex, 'technical')
        
        ## Include an organisation object
        ox = ex.xpath('xmlns:Organization[1]')
        org = Organisation.new
        if ox
          org.name         = ox.xpath('xmlns:OrganizationName[1]')[0].content
          org.display_name = ox.xpath('xmlns:OrganizationDisplayName[1]')[0].content
          org.url          = ox.xpath('xmlns:OrganizationURL[1]')[0].content
        end
        entity.organisation = org
    
        ## Collect this entity in the federation object
        federation.entities << entity
        
      end
       
      return federation
      
    end
    
    private
    
    ## DRY up the process of extracting Contact information
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
