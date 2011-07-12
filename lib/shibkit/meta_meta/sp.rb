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
            
      ## Element and attribute used to select XML for new objects
      ROOT_ELEMENT = 'EntityDescriptor'
      TARGET_ATTR  = 'entityID'
      REQUIRED_QUACKS = [:entity_uri, :valid?]
      
      MDUI_ROOT = 'SPSSODescriptor'
      
 
      attr_accessor :services
      
      attr_accessor :default_service
      
      
      private
      
      def parse_xml
        
        super
        
        @valid = @xml.xpath('xmlns:SPSSODescriptor[1]').empty?  ? false : true

      end
      
    end


  end
end
