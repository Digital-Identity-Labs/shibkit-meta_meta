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

    ## Class to represent a Shibboleth Federation or collection of local metadata
    ## 
    class Federation < MetadataItem
      
      require 'shibkit/meta_meta/metadata_item'
      
      
      ## Element and attribute used to select XML for new objects
      ROOT_ELEMENT = 'EntitiesDescriptor'
      TARGET_ATTR  = 'Name'
      REQUIRED_QUACKS = [:metadata_id, :federation_uri, :source_file]
      
      ## The unique ID of the federation document (probably time/version based)
      attr_accessor :metadata_id
      
      ## @return [String] the full name of the federation or collection
      attr_accessor :name
      
      ## The human-readable display name of the Federation or collection of metadata
      attr_accessor :display_name
      
      ## The URI name of the federation (may be missing for local collections)
      attr_accessor :federation_uri
      alias :uri :federation_uri
      
      ## Expiry date of the published metadata file
      attr_accessor :valid_until
      
      ## Source file for this federation
      attr_accessor :source_file
      
      ## @return [String] :federation for proper federations, :collection for 
      ##   simple collections of entities.
      attr_accessor :type
      
      ## @return [Array] country codes for areas served by the federation 
      attr_accessor :countries
      
      ## @return [String, nil] URL of the federation's Refeds wiki entry
      attr_accessor :refeds_url
      
      ## @return [String] URL of the federation or collection's home page
      attr_accessor :homepage_url
      
      ## @return [Array] Array of languages supported by the federation or collection
      attr_accessor :languages
      
      ## @return [String] Main contact email address for the federation 
      attr_accessor :support_email
      
      ## @return [String] Brief description of the federation or collection
      attr_accessor :description

      ## Array of entities within the federation or metadata collection
      attr_accessor :entities  

      attr_accessor :trustiness
      
      attr_accessor :groups
      
      attr_accessor :tags
      
      ## Time the Federation metadata was parsed
      attr_reader :read_at
      
      def to_s
        
        return uri
        
      end
      
      private
      
      ## Special case for federation top-level nodes
      def select_xml(target=nil, options={})
      
        raise "No suitable XML was selected" unless @xml and
          @xml.kind_of?(Nokogiri::XML::Element) and
          @xml.name == ROOT_ELEMENT 
      
      end
      
      ## Build a federation object out of metadata XML
      def parse_xml
        
        self.metadata_id    = @xml['ID'].to_s.strip
        self.federation_uri = @xml['Name'].to_s.strip
        self.valid_until    = @xml['validUntil'].strip
        self.entities       = Array.new
        
        ## Process XML chunk for each entity in turn
        @xml.xpath("//xmlns:EntityDescriptor").each do |ex|
        
          entity = Entity.new(ex)
          entity.primary_federation_uri = self.federation_uri
        
          ## Collect this entity in the federation object
          self.entities << entity
          
        end

      end
      

      
    end
  end
end