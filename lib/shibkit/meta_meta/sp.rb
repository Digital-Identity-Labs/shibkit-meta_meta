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
  
    ## Class to represent an SP
    class SP < Provider
      
      
      require 'shibkit/meta_meta/service'
      require 'shibkit/meta_meta/requested_attribute'
      
      ## Element and attribute used to select XML for new objects
      ROOT_ELEMENT = 'EntityDescriptor'
      TARGET_ATTR  = 'entityID'
      REQUIRED_QUACKS = [:entity_uri, :valid?]
      
      MDUI_ROOT = 'SPSSODescriptor'
      
 
      attr_accessor :services
      
      attr_accessor :default_service
      
      attr_accessor :protocols
      
      private
      
      def parse_xml
        
        super
        
        @valid = @xml.xpath('xmlns:SPSSODescriptor[1]').empty?  ? false : true

        proto_set = @xml.xpath('xmlns:SPSSODescriptor/@protocolSupportEnumeration')[0]
        @protocols = proto_set.value.split(' ') if proto_set 
        
        ## Include services objects
        @services ||= Array.new
        @xml.xpath("xmlns:SPSSODescriptor/xmlns:AttributeConsumingService").each do |sx|
          
          service = Shibkit::MetaMeta::Service.new(sx).filter

          next unless service
          
          @services << service
          @default_service = service if service.default?
          
        end
        
        @services.sort! { |a,b| a.index <=> b.index }
        @default_service = @services[0] unless @default_service
        
      end
      
    end


  end
end
