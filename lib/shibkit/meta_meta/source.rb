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
        'wayf'       => 'http://sdss.ac.uk/2006/06/WAYF'
      }
      
      ## @return [String] the URI identifier for the federation or collection
      attr_accessor :name_uri
      
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
      attr_accessor :refeds_info
      
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
      
      private
            
      attr_reader   :metadata_tmpfile
      attr_reader   :certificate_tmpfile
      
      public
      
      ## New Source object with default values
      ## @return [Source]
      def initialize(&block)
  
        @uuid       = UUID.new.generate
        @name_uri   = "urn:uuid:" + @uuid
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
      
        return IO.read(metadata_tmpfile.path)
    
      end
    
      ## Return Nokogiri object tree for the metadata
      ## @return [Nokogiri::XML::Document] Nokogiri document
      def parse
        
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
    
      ## Does the source object look sensible?
      ## @return [TrueClass, FalseClass] True or false
      def ok?
    
        return false unless metadata_source and metadata_source.size > 1
    
        return true
    
      end
      
      private
        
      ## Copy a filesystem file into the working directory (slower but safer)  
      def fetch_local(filename)
        
        file_path = File.absolute_path(filename)
        raise unless File.exists?(file_path) and File.readable?(file_path)
        
        file = Tempfile.new(uuid)
        open(file_path, 'w') { |f| f << http_response.to_s }
        
        return file
        
      end
      
      ## Copy a remote file into the working directory, also caching it for next update
      def fetch_remote(url)
        
        Source.init_caches 
             
        http_response = RestClient.get(url)
        
        file = Tempfile.new(uuid)
        open(file.path, 'w') { |f| f << http_response.to_s }
        
        return file
      
      end
      
      public
      
      ##
      ## Class Methods
      ##
      
      ## Forcibly set environment (not normally needed)
      ## @return [String]
      def self.config=(config_opts)
        
        @auto_refresh = config[:auto_refresh] if config[:auto_refresh]
        @environment  = config[:environment].to_sym if config[:environment]
        @verbose      = config[:verbose]      if config[:verbose]
        @logfile      = config[:logfile]      if config[:logfile] 
        
        return true
        
      end
      
      ## Load a metadata source list from a YAML file
      ## @param [String] source_list Filesystem path of a sources YAML file or
      ##   :real for included list of real sources, :dev for mock sources, or
      ##   :auto for either :real or :dev, based on environment
      ## @return [Hash] Hash of source objects keyed by their URI IDs.
      def self.load(source_list=:auto, options={})
        
        case source_list
        when :auto
          file = Sources.in_production? ? REAL_SOURCES_FILE : DEV_SOURCES_FILE
        when :dev, :test
          file = DEV_SOURCES_FILE
        when :real, :prod, :production
          file = REAL_SOURCES_FILE
        else
          file = source_list
        end
        
        sources = Hash.new
        source_data = YAML::load(File.open(file))
        source_data.each_pair do |id, data|
          
          Source.new do |source|
            
            source.name_uri      = id
            source.name          = data['name'] || id
            source.refresh_delay = data['refresh'].to_i || 86400
            source.display_name  = data['display_name'] || data['name'] || id
            source.type          = data['type'].to_sym || :collection
            source.countries     = data['countries'] || []
            source.metadata_source    = data['metadata']
            source.certificate_source = data['certificate']
            source.fingerprint   = data['fingerprint']
            source.refeds_info   = data['refeds_info']
            source.homepage      = data['homepage']
            source.languages     = data['languages'] || ['en']
            source.support_email = data['support_email'] || nil
            source.description   = data['description'] || ""
            
            sources[id] = source
            
          end
       
        end
               
        ## Options parsing for filtering, etc would go here, but not sure if 
        ## actually needed. Going with YAGNI and just skipping it for now...
        # ...
          
        return sources 
        
      end
    
      ## Options to set how remote files are cached and expired
      ## @param [Hash] Rack::Cache compatible hash of options
      ## @see http://rtomayko.github.com/rack-cache/ Rack::Cache for more information
      def self.cache_options=(options)
        
        @cache_options.merge(options) if cache_options and options.size > 0
        
      end      

      private
      
      ## Returns hash of options to set how remote files are cached and expired
      def self.cache_options
        
        unless @cache_options 
          
          cache_root = Source.cache_root
        
          @cache_options = {
            :verbose     => self.verbose?,
            :metastore   => Addressable::URI.convert_path(File.join(cache_root, 'meta')).to_s,
            :entitystore => Addressable::URI.convert_path(File.join(cache_root, 'body')).to_s            
          }
        
        end
        
        return @cache_options
        
      end
      
      
      ## Forcibly set environment (not normally needed)
      ## @return [String]
      def self.environment
      
        return @environment || 'production'
        
      end
      
      ## Send progress information to STDOUT
      ## @return [String]
      def self.verbose?
      
       return @verbose || false
        
      end
      
      ## Send progress information to STDOUT
      ## @return [String]
      def self.log_file
      
        return @log_file || nil
        
      end
      
      ## Send progress information to STDOUT
      ## @return [String]
      def self.auto_refresh?
      
       return @auto_refresh || false
        
      end
      
      ## Work out if we are in production or not by snooping on environment
      ## This is a magical bodge to make :auto option in #load vaguely useful
      def self.in_production?

        return true if Source.environment == :production
        return true if defined? Rails and Rails.env.production? 
        return true if defined? Rack and defined? RACK_ENV and RACK_ENV == 'production'
        
      end
      
      ## Are we on a POSIX standard system or on MS-DOS/Windows, etc?
      def self.sensible_os?
        
        return Config::CONFIG['host_os'] =~ /mswin|mingw/ ? false : true
        
      end
      
      ## Calculate the filesystem path to store the web cache
      def self.cache_root
        
        tmp_dir  = sensible_os? ? '/tmp' : ENV['TEMP']
        base_dir = File.join(tmp_dir, 'skmm-cache')
        
        return base_dir
        
      end
      
      ## Create the web cache 
      def self.init_caches
        
        @initialised_caches ||= false
        
        unless @initialised_caches
          
          ## JIT loading of the Cache module so we ca set options first
          RestClient.enable Rack::Cache, Source.cache_options
          
          ## Allow user to write log of all downloads in a standard format
          if self.log_file
           
            RestClient.enable Rack::CommonLogger, self.log_file
          
          else
            
            RestClient.disable Rack::CommonLogger
          
          end
          
          ## Helps if the locations actually exist, of course.
          FileUtils.mkdir_p File.join(cache_root, 'meta')
          FileUtils.mkdir_p File.join(cache_root, 'body')
          
          @initialised_caches = true
  
        end
        
      end
      
    end
  end
end