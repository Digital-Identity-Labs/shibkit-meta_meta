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
    class Entity < Metadata
      
      require 'shibkit/meta_meta/metadata'
      
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

      ## Show in normal WAYFs?
      attr_accessor :hide
     
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
      alias :hide? :hide
      alias :accountable? :accountable
      alias :athens? :athens
      alias :organization :organisation
      
      private
      
      def parse_xml
        
        self.entity_uri     = @xml['entityID']
        self.metadata_id    = @xml['ID']
      
        ## Then boolean flags for common/useful info 
        self.accountable = @xml.xpath('xmlns:Extensions/ukfedlabel:AccountableUsers').size   > 0 ? true : false
        self.ukfm        = @xml.xpath('xmlns:Extensions/ukfedlabel:UKFederationMember').size > 0 ? true : false
        self.athens      = @xml.xpath('xmlns:Extensions/elab:AthensPUIDAuthority').size      > 0 ? true : false
        self.hide        = @xml.xpath('xmlns:Extensions/wayf:HideFromWAYF').size             > 0 ? true : false
        self.scopes      = @xml.xpath('xmlns:IDPSSODescriptor/xmlns:Extensions/shibmd:Scope').collect { |x| x.text }
        self.idp         = @xml.xpath('xmlns:IDPSSODescriptor') ? true : false
        self.sp          = @xml.xpath('xmlns:SPSSODescriptor')  ? true : false
        
        ## Include Contact objects
        self.support_contact   = Contact.new(@xml.xpath("xmlns:ContactPerson[@contactType='support'][1]")[0])
        self.technical_contact = Contact.new(@xml.xpath("xmlns:ContactPerson[@contactType='technical'][1]")[0])
        
        ## Include an organisation object
        self.organisation = Organisation.new(@xml.xpath('xmlns:Organization[1]'))
       
      end
      
    end


    end
  end
  