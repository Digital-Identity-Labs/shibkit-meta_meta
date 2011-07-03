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
require 'rbconfig'
require 'tempfile'
require 'addressable/uri'
require 'fileutils'

module Shibkit
  class MetaMeta
    
    ## 
    ##
    class Source
      
      REAL_SOURCES_FILE = "#{::File.dirname(__FILE__)}/data/real_sources.yml"
      DEV_SOURCES_FILE  = "#{::File.dirname(__FILE__)}/data/dev_sources.yml"
        
      AUTO_REFRESH = true
        
      attr_accessor :name_uri
      attr_accessor :name
      attr_accessor :refresh_delay
      attr_accessor :cache
      attr_accessor :display_name
      attr_accessor :type
      attr_accessor :countries
      attr_accessor :metadata_source
      attr_accessor :certificate_source
      attr_accessor :fingerprint
      attr_accessor :refeds_info
      attr_accessor :homepage
      attr_accessor :languages
      attr_accessor :support_email
      attr_accessor :description
      
      attr_reader   :uuid
      attr_reader   :fetched_at
      attr_reader   :message
      attr_reader   :status
      
      private
            
      attr_reader   :metadata_local_file
      attr_reader   :certificate_local_file
      
      public
      
      ## New default object
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
        @certificate_local_file = nil
        @metadata_local_file    = nil
        
        self.instance_eval(&block) if block
  
      end
      
      ## Redownload remote file
      def refresh
        
        fetch_metadata
        fetch_certificate
        
        raise "Validation error" unless valid?
        
      end
      
      ## Fetch remote file and store locally 
      def fetch_metadata
         
        @metadata_local_file = case metadata_source
          when /^http/
            fetch_remote(metadata_source)
          else
            fetch_local(metadata_source)
         end
         
         @fetched_at = Time.new
         
      end  

      ## Fetch remote file and store locally 
      def fetch_certificate
         
         @certificate_local_file = case certificate_source
           when /^http/
             fetch_remote(certificate_source)
           else
             fetch_local(certificate_source)
          end
         
      end  
      
      def validate
        
        ## Check that XML is valid
        # ...
        
        ## Check that certificate is OK
        # ...
        
        ## Check that metadata has been signed OK, prob. Using XMLSecTool?
        # ...
        
        return true
        
      end
      
      def valid?
        
        return true if validate
        
      end
      
      def certificate_pem
        
        ## Deal with caching locally, downloading, etc
        refresh if AUTO_REFRESH and @certificate_local_file == nil
        
        return IO.read(certificate_local_file.path)
        
      end

      ## Return raw source string from the file
      def content
        
        ## Deal with caching locally, downloading, etc
        refresh if AUTO_REFRESH and @metadata_local_file == nil
      
        return IO.read(metadata_local_file.path)
    
      end
    
      ## Return Nokogiri object for the metadata
      def parse
        
        ## Parse the entire file as an XML document
        doc = Nokogiri::XML.parse(content) do |config|
          config.strict.noent.dtdvalid
        end
          
        xml  = doc.root

        ## Add exotic namespaces to make sure we can deal with all metadata # TODO
        xml.add_namespace_definition('ukfedlabel','http://ukfederation.org.uk/2006/11/label')
        xml.add_namespace_definition('elab','http://eduserv.org.uk/labels')
        xml.add_namespace_definition('wayf','http://sdss.ac.uk/2006/06/WAYF')
       
        return xml
       
      end
    
      ## Does the source object look sensible?
      def ok?
    
        return false unless metadata_source and metadata_source.size > 1
    
        return true
    
      end
    
      ##
      ## Class Methods
      ##
      
      ## Forcibly set environment (not normally needed)
      def self.environment=(mm_env)
      
        return @environment = mm_env
      
      end
      
      ## Forcibly set environment (not normally needed)
      def self.environment
      
        return @environment
        
      end
      
      ## Send progress information to STDOUT
      def self.noisy=
      
        # ...
        
      end
      
      ## Send progress information to STDOUT
      def self.log_to=
      
        # ...
        
      end
      
      ## Load a metadata source list 
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
            source.refresh_delay = data['refresh'] || 86400
            source.cache         = data['cache'] || true
            source.display_name  = data['display_name'] || data['name'] || id
            source.type          = data['type'] || 'collection'
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
    
      private
          
      def fetch_local(filename)
        
        file_path = File.absolute_path(filename)
        raise unless File.exists?(file_path) and File.readable?(file_path)
        
        file = Tempfile.new(uuid)
        open(file_path, 'w') { |f| f << http_response.to_s }
        
        return file
        
      end
      
      def fetch_remote(url)
        
        Source.init_caches 
             
        http_response = RestClient.get(url)
        
        file = Tempfile.new(uuid)
        open(file.path, 'w') { |f| f << http_response.to_s }
        
        return file
      
      end
      
      ##
      ## Class Methods
      ##
      
      public
      
      def self.cache_options
        
        unless @cache_options 
          
          cache_root = Source.cache_root
        
          @cache_options = {
            :verbose     => false,
            :metastore   => Addressable::URI.convert_path(File.join(cache_root, 'meta')).to_s,
            :entitystore => Addressable::URI.convert_path(File.join(cache_root, 'body')).to_s            
          }
        
        end
        
        return @cache_options
        
      end
      
      ## Hash of Rack::Cache options
      def self.cache_options=(options)
        
        @cache_options.merge(options) if cache_options and options.size > 0
        
      end      

      private
      
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
          
          ## Helps if the locations actually exist, of course.
          FileUtils.mkdir_p File.join(cache_root, 'meta')
          FileUtils.mkdir_p File.join(cache_root, 'body')
          
          @initialised_caches = true
  
        end
        
      end
      
    end
  end
end