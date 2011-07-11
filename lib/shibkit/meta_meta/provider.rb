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
    
    require 'shibkit/meta_meta/metadata_item'
    
    ## Class to represent the metadata of a Shibboleth IDP or SP 
    class Provider < MetadataItem
      
      require 'shibkit/meta_meta/logo'
      
      ## Element and attribute used to select XML for new objects
      ROOT_ELEMENT = 'EntityDescriptor'
      TARGET_ATTR  = 'entityID'
      REQUIRED_QUACKS = [:entity_uri]
      
      MDUI_ROOT    = 'NotSpecified'
      
      ## The URI of the entity
      attr_accessor :entity_uri
      
      attr_accessor :display_names
      
      attr_accessor :descriptions
      
      attr_accessor :keyword_sets
      
      attr_accessor :info_urls
      
      attr_accessor :privacy_urls
      
      attr_accessor :ip_blocks
      
      attr_accessor :domains
      
      attr_accessor :geolocation_urls
      
      attr_reader   :valid
       
      alias :entity_id :entity_uri
      alias :valid?    :valid
      
      
      def display_name(lang=:en)
        
        return display_names[lang] unless display_names[lang].to_s.empty?
        return service_name unless service_name.to_s.empty?
        return entity_id
        
      end
      
      def description(lang=:en)
        
        return descriptions[lang] unless descriptions[lang].to_s.empty?
        return service_description unless service_description.to_s.empty?
        return organisation.display_name if (organisation and ! organisation.display_name.to_s.empty?)
        return organisation.name if (organisation and ! organisation.name.to_s.empty?)
        return "" 
        
      end
      
      def keywords(lang=:en)
      
        return keyword_sets[lang] || []
      
      end
      
      def info_url(lang=:en)
        
        return info_urls[lang] || nil
        
      end
      
      def privacy_url(lang=:en)
        
        return privacy_urls[lang] || nil
        
      end
      
      def logos(lang=:en)
        
        return logos[lang] || []
        
      end
      
      private
      
      def parse_xml
        
        self.entity_uri     = @xml['entityID']
        
        mdui_root = self.class::MDUI_ROOT
        
        ## Display names
        @display_names = extract_lang_map_of_strings("xmlns:#{mdui_root}/xmlns:Extensions/mdui:UIInfo/mdui:DisplayName")
        
        ## Descriptions
        @descriptions = extract_lang_map_of_strings("xmlns:#{mdui_root}/xmlns:Extensions/mdui:UIInfo/mdui:Description")
        
        ## Keywords
        @keyword_sets = extract_lang_map_of_string_lists("xmlns:#{mdui_root}/xmlns:Extensions/mdui:UIInfo/mdui:Keywords")
            
        ## Information URLs
        @info_urls = extract_lang_map_of_strings("xmlns:#{mdui_root}/xmlns:Extensions/mdui:UIInfo/mdui:InformationURL")

        ## Privacy Statement URLs
        @privacy_urls = extract_lang_map_of_strings("xmlns:#{mdui_root}/xmlns:Extensions/mdui:UIInfo/mdui:PrivacyStatementURL")

        ## Logos
        @logos = extract_lang_map_of_objects("xmlns:#{mdui_root}/xmlns:Extensions/mdui:UIInfo/mdui:Logo",
          Shibkit::MetaMeta::Logo)
        
        ## IP Address Ranges
        @ip_blocks = extract_simple_list("xmlns:#{mdui_root}/xmlns:Extensions/mdui:DiscoHints/mdui:IPHint")
        
        ## DNS Domain Names
        @domains = extract_simple_list("xmlns:#{mdui_root}/xmlns:Extensions/mdui:DiscoHints/mdui:DomainHint")
        
        ## Geolocations
        @geolocations = extract_simple_list("xmlns:#{mdui_root}/xmlns:Extensions/mdui:DiscoHints/mdui:GeolocationHint")
  
      end
      
    end

  end
end
