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

module Shibkit
  class MetaMeta
    
    ## Class to represent the metadata of a Shibboleth IDP or SP 
    class Entity < MetadataItem
      
      require 'shibkit/meta_meta/metadata_item'
      require 'shibkit/meta_meta/contact'
      require 'shibkit/meta_meta/idp'
      require 'shibkit/meta_meta/sp'
      require 'shibkit/meta_meta/organisation'
      
      ## Element and attribute used to select XML for new objects
      ROOT_ELEMENT = 'EntityDescriptor'
      TARGET_ATTR  = 'entityID'
      REQUIRED_QUACKS = [:entity_uri]
      
      LINE_START = "<!--"
      LINE_END   = "-->"
      HR_CHAR    = "="
      
      ## The URI of the entity
      attr_accessor :entity_uri
      alias    :uri :entity_uri
      
      ## The URI of the entity's parent federation
      attr_accessor :primary_federation_uri
      
      ## The URI of the entity's parent federation
      attr_accessor :other_federation_uris
      alias :secondary_federation_uris :other_federation_uris
      
      ## Has this entity object been selected to represent the service?
      attr_accessor :primary
      
      ## The ID of the entity with the metadata file (not globally unique)
      attr_accessor :metadata_id

      ## Is the entity accountable?
      attr_accessor :accountable
      
      ## Is the entity part of the UK Access Management Federation?
      attr_accessor :ukfm
      
      ## Is the entity using Athens?
      attr_accessor :athens

      ## Show in normal WAYFs?
      attr_accessor :hide
  
      attr_accessor :scopes
      
      ## Organisation object for the owner of the entity 
      attr_accessor :organisation
      
      ## Contact object containing user support contact details
      attr_accessor :support_contact
      
      ## Contact object containing technical contact details
      attr_accessor :technical_contact
      
      ## Contact object containing technical contact details
      attr_accessor :admin_contact
      
      ## Is the entity an IDP?
      attr_accessor :idp
      
      ## Is the entity an SP?
      attr_accessor :sp
                    
      alias :entity_id :entity_uri
      alias :ukfm? :ukfm
      alias :hide? :hide
      alias :accountable? :accountable
      alias :athens? :athens
      alias :organization :organisation
      
      def to_s
        
        return uri
        
      end
      
      def idp? 
        
        return idp.kind_of?(::Shibkit::MetaMeta::IDP)
        
      end
      
      def sp?
        
        return sp.kind_of?(::Shibkit::MetaMeta::SP)
        
      end
      
      def urn?

        return uri.strip.downcase[0..3] == 'urn:'
        
      end
      
      ##
      def primary?
        
        return @primary ? true : false
        
      end
      
      def multi_federated?
        
        return other_federation_uris.size > 0 ? true : false
        
      end
      
      ## All federations that this entity is a member of
      def federation_uris

        ## All unique federations, making sure we include primary
        all_fed_uris = [primary_federation_uri].concat other_federation_uris 
        
        return all_fed_uris.uniq
      
      end
      
      def tags=(tags)
        
        @tags ||= []
        
        if Shibkit::MetaMeta.config.auto_tag?
          
          @tags << :idp if idp?
          @tags << :sp  if sp?
          
        end
        
        @tags = @tags.concat([tags].flatten).uniq
       
      end
      
      def tags
        
        return @tags.nil? ? [] : @tags.collect { |t| t.to_sym }
        
      end
      
      def xml_comment

        out = "\n" + LINE_START + (HR_CHAR * 71) + LINE_END + "\n"
        out << LINE_START + " " + uri + " "  + LINE_END  + "\n"
        out << LINE_START + (HR_CHAR * 71) + LINE_END + "\n\n"
        
        return out
        
      end
      
      private
      
      def parse_xml
        
        self.entity_uri     = @noko['entityID'].to_s.strip
        self.metadata_id    = @noko['ID'].to_s.strip
         
        @other_federation_uris        ||= Array.new
              
        ## Boolean flags for common/useful info 
        self.accountable = @noko.xpath('xmlns:Extensions/ukfedlabel:AccountableUsers').size   > 0 ? true : false
        self.ukfm        = @noko.xpath('xmlns:Extensions/ukfedlabel:UKFederationMember').size > 0 ? true : false
        self.athens      = @noko.xpath('xmlns:Extensions/elab:AthensPUIDAuthority').size      > 0 ? true : false
        self.hide        = @noko.xpath('xmlns:Extensions/wayf:HideFromWAYF').size             > 0 ? true : false
        
        @scopes = @noko.xpath('xmlns:Extensions/shibmd:Scope').collect do |sx|
        
         sx['regexp'] == 'true' ? Regexp.new(sx.text) : sx.text  
          
        end
        
        ## IDP and SP objects, if available. Based on the same XML as their parent/entity object
        self.idp         = Shibkit::MetaMeta::IDP.new(@noko).filter
        self.sp          =  Shibkit::MetaMeta::SP.new(@noko).filter
        
        ## Include Contact objects
        self.support_contact   = Contact.new(@noko.xpath("xmlns:ContactPerson[@contactType='support'][1]")[0]).filter
        self.technical_contact = Contact.new(@noko.xpath("xmlns:ContactPerson[@contactType='technical'][1]")[0]).filter
        self.admin_contact     = Contact.new(@noko.xpath("xmlns:ContactPerson[@contactType='administrative'][1]")[0]).filter
        
        ## Include an organisation object
        self.organisation     = Organisation.new(@noko.xpath("xmlns:Organization[1]")[0]).filter
        self.idp.organisation = self.organisation if idp?
        self.sp.organisation  = self.organisation if sp?
        
        self.tags ||= []
       
        log.debug " Derived entity #{self.uri} from XML"
        
      end
      
    end


  end
end
  