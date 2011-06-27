## @author    Pete Birkinshaw (<pete@digitalidentitylabs.com>)
## Copyright: Copyright (c) 2011 Digital Identity Ltd.
## License:   Apache License, Version 2.0

## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
## 
##     http://www.apache.org/licenses/LICENSE-2.0
## 
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##

require 'rubygems'
require 'nokogiri'
require 'yaml'

require 'shibkit/metameta/contact'
require 'shibkit/metameta/source'
require 'shibkit/metameta/entity'
require 'shibkit/metameta/federation'
require 'shibkit/metameta/organisation'

module Shibkit
  
  ## Simple library to parse Shibboleth metadata files into Ruby objects
  class MetaMeta
        
    ## Easy access to Shibkit's configuration settings
    include Shibkit::Configured
    
    attr_accessor :sources
    attr_accessor :federations
        
    ## New default object
    def initialize(&block)
    
      @sources     = Array.new
      @federations = Array.new
      @read_at     = nil
      
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
      
        @federations << MetaMeta.parse(source)
        @read_at     = Time.new
        
      end
      
    end 
    
    ## Loads federation metadata contents 
    def load_cache_file(file_or_url)
        
        @federations = YAML::load(File.open(file_or_url))
        
        return true
        
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
        
      return true
        
    end    
    
    ## Parses a string containing metadata XML and returns a federation object
    def MetaMeta.parse(source)
      
      ## Parse the entire file as an XML document
      doc = Nokogiri::XML.parse(source.content) do |config|
        config.strict.noent.dtdvalid
      end
      
      ## Find the Federation level metadata xml, if present
      federation = Federation.new
      fx  = doc.root
      
      ## Add exotic namespaces to make sure we can deal with all metadata # TODO
      fx.add_namespace_definition('ukfedlabel','http://ukfederation.org.uk/2006/11/label')
      fx.add_namespace_definition('elab','http://eduserv.org.uk/labels')
      
      ## Extract basic 'federation' information 
      federation.display_name   = source.name
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
