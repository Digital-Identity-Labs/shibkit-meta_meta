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
    class MetadataItem
      
      require 'nokogiri'
      
      ## Element and attribute used to select XML for new objects
      ROOT_ELEMENT    = 'SomeThingThatIsntThere'
      TARGET_ATTR     = 'ID'
      REQUIRED_QUACKS = [:bananas]
      
      ## Additional namespaces that Nokogiri needs to know about
      NAMESPACES = {
        'ukfedlabel' => 'http://ukfederation.org.uk/2006/11/label',
        'elab'       => 'http://eduserv.org.uk/labels',
        'wayf'       => 'http://sdss.ac.uk/2006/06/WAYF',
        'mdui'       => 'urn:oasis:names:tc:SAML:metadata:ui'
      }
      
      ## New object takes XML (as libXML object or text)
      def initialize(source_xml=nil, target=nil, options={}, &block)
        
        @read_at = Time.new
        
        ## Use XML to build object
        if source_xml
          
          prepare_xml(source_xml)
          select_xml(target, options)
          parse_xml
          
        end
        
        ## Use block for further configuration or manual creation
        self.instance_eval(&block) if block

      end
      
      ## Make sure the object is suitable. Return nil if bad, object if good
      def filter
        
        ## Make sure this object quacks like the suitable variety of duck
        self.class::REQUIRED_QUACKS.each do |method|
          
          return nil unless self.respond_to? method
          return nil unless self.send(method)
        
        end
        
        return self
        
      end
      
      def to_hash
        
        return {}
        
      end
      
      def to_json
        
        return to_hash.to_json
        
      end
      
      def to_rdf
        
        return
        
      end
      
      private
      
      ## Make sure we have consistent Nokogiri document whether string or Nokogiri passed
      def prepare_xml(source_xml)
      
        @xml = source_xml
        
        if @xml.kind_of? String
          
          ## Parse the entire file as an XML document
          doc = Nokogiri::XML.parse(@xml) do |config|
            config.strict.noent.dtdvalid
          end
          
          @xml  = doc.root
          
          ## Add exotic namespaces to make sure we can deal with all metadata
          NAMESPACES.each_pair { |label, uri| @xml.add_namespace_definition(label,uri) }

        end

        ## Make sure we get an element object...
        @xml = @xml.at('/') if @xml.kind_of? Nokogiri::XML::NodeSet
        @xml = @xml.root if @xml.kind_of? Nokogiri::XML::Document

        raise "Unsuitable data!" unless @xml and @xml.respond_to? 'name'
        
      end
      
      ## If a target is specified select first matching node, otherwise just grab first node of type
      def select_xml(target=nil, options={})

        unless @xml.name == self.class::ROOT_ELEMENT ## and check for target too 
             
          if target and TARGET_ATTR
            selector = "xmlns:#{self.class::ROOT_ELEMENT}[@#{self.class::TARGET_ATTR}='#{target}'][1]"
            @xml = @xml.xpath(selector)[0]
          else
            selector = "xmlns:#{self.class::ROOT_ELEMENT}[1]"
            @xml = @xml.xpath(selector)[0]
          end  
          
          raise "No suitable XML was selected: using #{selector} from a #{@xml.name} node" unless @xml and
            @xml.kind_of?(Nokogiri::XML::Element) and @xml.name
          
        end
        
      end
      
      ## Process XML to define object attributes
      def parse_xml

        raise "parse_xml method has not been implemented in this class"
        
      end
      
      def purge_xml
        
        @xml = nil
        
      end
      
    end
  end
end