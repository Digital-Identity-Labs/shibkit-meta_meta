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

    ## Class to represent technical or suppor contact details for an entity
    class Contact < MetadataItem
      
      require 'shibkit/meta_meta/metadata_item'
      
      ## Element and attribute used to select XML for new objects
      ROOT_ELEMENT = 'ContactPerson'
      TARGET_ATTR  = 'contactType'
      REQUIRED_QUACKS = [:email_url, :category]
      
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
      
      def email_address
        
        return email_url.gsub('mailto:','')
        
      end
      
      ## Nicer presentation as a string
      def to_s
        
        return "#{display_name} <#{email_address}>"
       
      end
      
      private
      
      def parse_xml
        
        if @noko and @noko.content
             
          self.givenname = @noko.xpath('xmlns:GivenName[1]')[0].content    if @noko.xpath('xmlns:GivenName[1]')[0]
          self.surname   = @noko.xpath('xmlns:SurName[1]')[0].content      if @noko.xpath('xmlns:SurName[1]')[0]
          self.email_url = @noko.xpath('xmlns:EmailAddress[1]')[0].content if @noko.xpath('xmlns:EmailAddress[1]')[0]
          self.category  = @noko['contactType'].to_sym
        
          log.debug "  Derived contact #{email_url} from XML"
        
        end
        
        
        
      end

    end
  end
end