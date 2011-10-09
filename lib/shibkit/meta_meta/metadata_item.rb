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
      require 'uuid'
      
      ## A few simple utility functions for slurping data from XML
      require 'shibkit/meta_meta/mixin/xpath_chores'
      include Shibkit::MetaMeta::Mixin::XPathChores
      
      
      ## Element and attribute used to select XML for new objects
      ROOT_ELEMENT    = 'SomeThingThatIsntThere'
      TARGET_ATTR     = 'ID'
      REQUIRED_QUACKS = [:bananas]
      
      ## Additional namespaces that Nokogiri needs to know about
      NAMESPACES = {
        'ukfedlabel' => 'http://ukfederation.org.uk/2006/11/label',
        'elab'       => 'http://eduserv.org.uk/labels',
        'wayf'       => 'http://sdss.ac.uk/2006/06/WAYF',
        'mdui'       => 'urn:oasis:names:tc:SAML:metadata:ui',
        'saml'       => 'urn:oasis:names:tc:SAML:2.0:assertion',
        'shibmd'     => 'urn:mace:shibboleth:metadata:1.0'
      }
      
      attr_reader :uuid
      attr_reader :read_at
      
      ## New object takes XML (as libXML object or text)
      def initialize(xml=nil, target=nil, options={}, &block)
        
        @uuid       = UUID.new.generate
        @read_at    = Time.new
        @noko       = nil
        @source_xml = nil
        
        ## Use XML to build object
        if xml
          
          prepare_xml(xml)
          select_xml(target, options)
          parse_xml
          #purge_xml
          
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
        
        raise "Not Implemented!"
        
        return {}
        
      end
      
      def to_rdf
        
        raise "Not Implemented!"
        
        return
        
      end
      
      def to_xml
        
        raise "Not Implemented!"
        
        return
        
      end
      
      def source_xml
        
        return @source_xml
        
      end
     
      def parsed_xml
        
        return @noko
        
      end
            
      def purge_xml
        
        @noko       = nil
        @source_xml = nil
        
        cascade_method(:purge_xml)
        
      end
      
      def textify_xml
        
        puts "textify called by #{self.to_s} #{self.class}"
        
        @noko = @noko.to_s
        
        cascade_method(:textify_xml)
        
      end
      
      
      
      private
      
      def cascade_method(method_name, *params) 
        
        method_name = method_name.to_sym

        self.instance_variables.each do |attr_name|
          
          puts attr_name 
          
          obj = instance_variable_get attr_name.to_sym
          
          values = obj.values if obj.respond_to? :values 
          values ||= [obj].flatten
          
          values.each do |value|
          
            if value.respond_to? method_name
            
              value.send method_name, *params
            
            end
          
          end
          
        end

      end
      
      ## Logging 
      def log
      
        return ::Shibkit::MetaMeta.config.logger
        
      end
      
      ## Make sure we have consistent Nokogiri document whether string or Nokogiri passed
      def prepare_xml(xml)
        
        if xml.kind_of? String
          
          ## Parse the entire file as an XML document
          doc = Nokogiri::XML.parse(xml) do |config|
            config.strict.noent.dtdvalid
          end
          
          @noko = doc.root

          ## Add exotic namespaces to make sure we can deal with all metadata
          NAMESPACES.each_pair { |label, uri| @noko.add_namespace_definition(label,uri) }
          
          @source_xml = xml
          
        end
        
        @noko ||= xml
        
        ## Make sure we get an element object...
        @noko = @noko.at('/') if @noko.kind_of? Nokogiri::XML::NodeSet
        @noko = @noko.root    if @noko.kind_of? Nokogiri::XML::Document

        raise "Unsuitable data!" unless @noko and @noko.respond_to? 'name'
        
      end
      
      ## If a target is specified select first matching node, otherwise just grab first node of type
      def select_xml(target=nil, options={})

        unless @noko.name == self.class::ROOT_ELEMENT ## and check for target too 
             
          if target and TARGET_ATTR
            selector = "xmlns:#{self.class::ROOT_ELEMENT}[@#{self.class::TARGET_ATTR}='#{target}'][1]"
            @noko = @noko.xpath(selector)[0]
          else
            selector = "xmlns:#{self.class::ROOT_ELEMENT}[1]"
            @noko = @noko.xpath(selector)[0]
          end  
          
          raise "No suitable XML was selected: using #{selector}" unless @noko and
            @noko.kind_of?(Nokogiri::XML::Element) and @noko.name
          
        end
        
      end
      
      ## Process XML to define object attributes
      def parse_xml

        raise "parse_xml method has not been implemented in this class"
        
      end
      

      
    end
  end
end