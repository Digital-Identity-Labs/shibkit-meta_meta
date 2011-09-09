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

require 'uuid'
require 'yaml'
require 'rest_client'
require 'restclient/components'
require 'rack/cache'
require 'rack/commonlogger'
require 'rbconfig'
require 'tempfile'
require 'addressable/uri'
require 'fileutils'

module Shibkit
  class MetaMeta
    
    ## 
    ##
    class Source
      
      require 'shibkit/meta_meta/mixin/cached_downloads'
      require 'shibkit/meta_meta/federation'
      
      include Shibkit::MetaMeta::Mixin::CachedDownloads
      
      ## @note This class currently lacks the ability to properly validate
      ##   metadata.
      
      ## Location of default real sources list (contains real-world federation details)
      REAL_SOURCES_FILE = "#{::File.dirname(__FILE__)}/data/real_sources.yml"
      
      ## Location of default mock sources list (contains small fictional federations)
      DEV_SOURCES_FILE  = "#{::File.dirname(__FILE__)}/data/dev_sources.yml"
      
      ## Additional namespaces that Nokogiri needs to know about
      NAMESPACES = {
        'ukfedlabel' => 'http://ukfederation.org.uk/2006/11/label',
        'elab'       => 'http://eduserv.org.uk/labels',
        'wayf'       => 'http://sdss.ac.uk/2006/06/WAYF',
        'mdui'       => 'urn:oasis:names:tc:SAML:metadata:ui',
        'saml'       => 'urn:oasis:names:tc:SAML:2.0:assertion',
        'shibmd'     => 'urn:mace:shibboleth:metadata:1.0'
      }
      
      ## @return [String] the URI identifier for the federation or collection
      attr_accessor :name_uri
      alias    :uri :name_uri
      
      ## @return [String] the full name of the federation or collection
      attr_accessor :name
      
      ## @return [String] the common, friendler name of the federation or collection
      attr_accessor :display_name
      
      ## @return [String] :federation for proper federations, :collection for 
      ##   simple collections of entities.
      attr_accessor :type
      
      ## @return [Fixednum] the recommended refresh period for the federation, in seconds
      attr_accessor :refresh_delay
      
      ## @return [Array] country codes for areas served by the federation 
      attr_accessor :countries
      
      ## @return [String] URL or filesystem path of the metadata file to be used 
      attr_accessor :metadata_source
      
      ## @return [String] URL or filesystem path of the metadata certificate to be used 
      attr_accessor :certificate_source
      
      ## @return [String, nil] Fingerprint of the federation certificate
      attr_accessor :fingerprint
      
      ## @return [String, nil] URL of the federation's Refeds wiki entry
      attr_accessor :refeds_url
      alias :refeds_info :refeds_url 
      
      ## @return [String] URL of the federation or collection's home page
      attr_accessor :homepage
      
      ## @return [Array] Array of languages supported by the federation or collection
      attr_accessor :languages
      
      ## @return [String] Main contact email address for the federation 
      attr_accessor :support_email
      
      ## @return [String] Brief description of the federation or collection
      attr_accessor :description
      
      ## @return [String] Unique UUID for the federation or collection
      attr_reader   :uuid
      
      ## @return [String] Time the metadata for this federation was last fetched
      ## @note This is not persistent between uses of this class
      attr_reader   :fetched_at
      
      ## @return [String] Message returned during processing
      ## @deprecated Not actually used at present, not sure if this is needed...
      attr_reader   :messages
      
      ## @return [String] Status of the source: indicates success of last operation
      attr_reader   :status
      
      attr_reader   :created_at
      
      private
            
      attr_reader   :metadata_tmpfile
      attr_reader   :certificate_tmpfile
      
      public
      
      ## New Source object with default values
      ## @return [Source]
      def initialize(&block)
  
        @uuid       = UUID.new.generate
        @name_uri   = "urn:uuid:" + @uuid
        @created_at = Time.new
        @name       = "Unnown"
        @refresh_delay = 86400
        @display_name = "Unknown"
        @type      = "federation"
        @countries = []
        @metadata_source = nil
        @certificate_source = nil
        @fingerprint = nil
        @refeds_info = nil
        @homepage  = nil
        @languages = []
        @support_email = nil
        @description = ""
        @certificate_tmpfile = nil
        @metadata_tmpfile    = nil
        
        self.instance_eval(&block) if block
  
      end
      
      def to_s
        
        return uri
        
      end
      
      ## Create a new source from a hash
      def self.from_hash(data, uri=nil)
        
        data = data.inject({}){|m,(k,v)| m[k.to_sym] = v; m}
        
        new_source = self.new do |source|
          
          source.name_uri           = data[:uri]  || uri
          source.name               = data[:name] || uri
          source.refresh_delay      = data[:refresh].to_i || 86400
          source.display_name       = data[:display_name] || data['name'] || uri
          source.type               = data[:type].to_sym  || :collection
          source.countries          = data[:countries]    || []
          source.metadata_source    = data[:metadata]
          source.certificate_source = data[:certificate]
          source.fingerprint        = data[:fingerprint]
          source.refeds_url         = data[:refeds_info]
          source.homepage           = data[:homepage]
          source.languages          = data[:languages]     || ['en']
          source.support_email      = data[:support_email] || nil
          source.description        = data[:description]   || ""
          
        end

        return new_source
        
      end
      
      ## Build a parsed Federation object containing Entitiess
      ## @return [Shibkit::MetaMeta::Federation]
      def to_federation
        
        fx = self.parse_xml

        federation = ::Shibkit::MetaMeta::Federation.new(fx)
                    
        ## Pass additional information from source into federation object  
        federation.display_name  = display_name || name
        federation.type          = type 
        federation.refeds_url    = refeds_info 
        federation.countries     = countries
        federation.languages     = languages
        federation.support_email = support_email
        federation.homepage_url  = homepage
        federation.description   = description
        
        return federation
        
      end
      
      ## Redownload and revalidate remote files for the source
      ## @return [TrueClass, FalseClass]
      def refresh
        
        fetch_metadata
        fetch_certificate
        
        raise "Validation error" unless valid?
        
        return true
        
      end
      
      ## Fetch remote file and store locally without validation
      ## @return [File] Open filehandle for the local copy of metadata file
      def fetch_metadata
         
        @metadata_tmpfile = case metadata_source
          when /^http/
            fetch_remote(metadata_source)
          else
            fetch_local(metadata_source)
         end
         
         @fetched_at = Time.new
         
         return @metadata_tmpfile
         
      end  

      ## Fetch remote file and store locally
      ## @return [File] open filehandle for the local copy of certificate file 
      def fetch_certificate
         
         @certificate_tmpfile = case certificate_source
           when /^http/
             fetch_remote(certificate_source)
           else
             fetch_local(certificate_source)
          end
         
         return @certificate_tmpfile
         
      end  
      
      ## Validates metadata and certificate or raises an exception
      ## @return [TrueClass, FalseClass]
      def validate
        
        ## Check that XML is valid
        # ...
        
        ## Check that certificate is OK
        # ...
        
        ## Check that metadata has been signed OK, prob. Using XMLSecTool?
        # ...
        
        return true
        
      end
      
      ## Checks validity of metadata and certificate without raising exceptions
      ## @return [TrueClass, FalseClass]
      def valid?
        
        begin
          return true if validate
        rescue
          return false
        end
        
      end
      
      ## The content of the certificate associated with the metadata
      ## @return [String, nil]
      def certificate_pem
        
        ## Deal with caching locally, downloading, etc
        refresh if Source.auto_refresh? and @certificate_tmpfile == nil
        
        return IO.read(certificate_tmpfile.path)
        
      end

      ## Return raw source string from the file
      ## @return [String] Metadata XML as text
      def content
                
        ## Deal with caching locally, downloading, etc
        refresh if Source.auto_refresh? and @metadata_tmpfile == nil
        
        raise "No content is available, source has not been downloaded" unless 
          metadata_tmpfile.path
        
        return IO.read(metadata_tmpfile.path)
    
      end
    
      ## Return Nokogiri object tree for the metadata
      ## @return [Nokogiri::XML::Document] Nokogiri document
      def parse_xml
        
        ## Parse the entire file as an XML document
        doc = Nokogiri::XML.parse(content) do |config|
          config.strict.noent.dtdvalid
        end

        ## Select the top node  
        xml  = doc.root
        
        ## Add exotic namespaces to make sure we can deal with all metadata # TODO
        NAMESPACES.each_pair { |label, uri| xml.add_namespace_definition(label,uri) }
        
        return xml
       
      end
      
      def read
        
        Nokogiri::XML::Reader(content)
        
        
      end
      
      ## Does the source object look sensible?
      ## @return [TrueClass, FalseClass] True or false
      def ok?
    
        return false unless metadata_source and metadata_source.size > 1
    
        return true
    
      end
            
      public
      
      ##
      ## Class Methods
      ##
      
      ## Load a metadata source list from a YAML file
      ## @param [String] source_list Filesystem path of a sources YAML file or
      ##   :real for included list of real sources, :dev for mock sources, or
      ##   :auto for either :real or :dev, based on environment
      ## @return [Array] Array of metadata source objects
      def self.load(source_list=:auto, options={})
        
        file = self.locate_sources_file(source_list)
        
        sources = Array.new
        source_data = YAML::load(File.open(file))
        source_data.each_pair do |id, data|
          
          sources << Source.from_hash(data, id)
       
        end
        
        return sources 
        
      end
      
      ## Return appropriate file path for 
      def self.locate_sources_file(source_list)
      
        case source_list
        when :auto
          file_path = self.in_production? ? REAL_SOURCES_FILE : DEV_SOURCES_FILE
        when :dev, :test
          file_path = DEV_SOURCES_FILE
        when :real, :prod, :production
          file_path = REAL_SOURCES_FILE
        else
          file_path = source_list
        end
        
        return file_path
        
      end
      
    end
  end
end