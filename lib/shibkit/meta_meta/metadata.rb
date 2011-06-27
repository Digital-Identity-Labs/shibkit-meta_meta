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

    ## Base class for all MetaMeta metadata classes
    class Metadata
      
      require 'nokogiri'
      
      ## New object takes XML (as libXML object or text)
      def initialize(source_xml=nil, &block)

        ## Use XML to build object
        if source_xml
          
          prepare_xml(source_xml) 
          parse_xml
        
        end
        
        @read_at = Time.new
        
        ## Use block for further configuration
        self.instance_eval(&block) if block
        
      end
      
      private
      
      def prepare_xml(source_xml)
      
        @xml = source_xml

        if @xml.kind_of? String
          
          ## Parse the entire file as an XML document
          doc = Nokogiri::XML.parse(@xml) do |config|
            config.strict.noent.dtdvalid
          end
          
          @xml  = doc.root

          ## Add exotic namespaces to make sure we can deal with all metadata # TODO
          @xml.add_namespace_definition('ukfedlabel','http://ukfederation.org.uk/2006/11/label')
          @xml.add_namespace_definition('elab','http://eduserv.org.uk/labels')
          @xml.add_namespace_definition('wayf','http://sdss.ac.uk/2006/06/WAYF')
          
        end
        
        ##raise "Unsuitable data!" unless @xml.
          
      end
      
      def parse_xml
        
        @xml
        
      end
      
      def purge_xml
        
        @xml = nil
        
      end
      
    end
  end
end