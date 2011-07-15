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
    
    require 'shibkit/meta_meta/provider'
    
    ## Class to represent an IDP 
    class IDP < Provider
      
      
      ## Element and attribute used to select XML for new objects
      ROOT_ELEMENT = 'EntityDescriptor'
      TARGET_ATTR  = 'entityID'
      REQUIRED_QUACKS = [:scopes, :valid?]
      
      MDUI_ROOT = 'IDPSSODescriptor'

      ## Scopes used by the entity (if an IDP)
      attr_accessor  :scopes
      attr_accessor  :protocols
      attr_accessor  :nameid_formats
      attr_accessor  :attributes
      
      private
      
      def parse_xml
        
        super
        
        @scopes = @xml.xpath('xmlns:IDPSSODescriptor/xmlns:Extensions/shibmd:Scope').collect do |sx|
        
         sx['regexp'] == 'true' ? Regexp.new(sx.text) : sx.text  
          
        end 
       
        
        @valid = @xml.xpath('xmlns:IDPSSODescriptor[1]').empty? ? false : true
        
        proto_set = @xml.xpath('xmlns:IDPSSODescriptor/@protocolSupportEnumeration')[0]
        @protocols = proto_set.value.split(' ') if proto_set 
        
        @nameid_formats ||= Array.new
        @xml.xpath('xmlns:IDPSSODescriptor/xmlns:NameIDFormat').each do |nx|
          
          @nameid_formats << nx.content
          
        end
        
        
  
        @attributes ||= Array.new
        @xml.xpath('xmlns:IDPSSODescriptor/saml:AttributeValue').each do |ax|
          
          @attributes << Shibkit::MetaMeta::IDP.new(ax).filter
          
        end
        
      end
      
    end


  end
end
