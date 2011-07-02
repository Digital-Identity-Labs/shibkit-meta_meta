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

require 'open-uri'
require 'uuid'
require 'tmpdir'
require 'httparty'

module Shibkit
  class MetaMeta
    
    ## 
    ##
    class Source
      
      REAL_SOURCES_FILE = "#{::File.dirname(__FILE__)}/data/real_sources.yml"
      DEV_SOURCES_FILE  = "#{::File.dirname(__FILE__)}/data/dev_sources.yml"
      
      puts REAL_SOURCES_FILE
      puts DEV_SOURCES_FILE
      
      attr_accessor :name_uri
      attr_accessor :name
      attr_accessor :refresh_delay
      attr_accessor :cache
      attr_accessor :display_name
      attr_accessor :type
      attr_accessor :countries
      attr_accessor :metadata
      attr_accessor :certificate
      attr_accessor :fingerprint
      attr_accessor :refeds_info
      attr_accessor :homepage
      attr_accessor :languages
      attr_accessor :support_email
      attr_accessor :description
      attr_accessor :fetched_at
      attr_accessor :message
      attr_accessor :status
  
      ## New default object
      def initialize(&block)
  
        @name_uri   = "urn:uuid:" + UUID.new.generate
        @name       = "Unnown"
        @refresh_delay = 86400
        @display_name = "Unknown"
        @type      = "federation"
        @countries = []
        @metadata = nil
        @certificate = nil
        @fingerprint = nil
        @refeds_info = nil
        @homepage  = nil
        @languages = []
        @support_email = nil
        @description = ""
        
        self.instance_eval(&block) if block
  
      end
      
      ## Redownload all remote files
      def refresh(force=false)
        
        
      end
      
      ## Fetch remote files and store locally 
      def fetch
        
        
      end
      
      ## Does the local working file need to be updated?
      def cache_expired?
      
      end
      
      def validate
        
      end
      
      def valid?
        
      end
      
      def size
        
      end
      
      ## Return raw source string from the file
      def content
        
        ## Deal with caching locally, downloading, etc
        # ...
      
        return IO.read(file)
    
      end
  
      ## Source is reachable, valid filename/URI, etc. Does not check content
      def ok?
    
        
        #return false unless File.exists?(file) and File.readable?(file) 
    
        #return true
    
      end
    
      ##
      ## Class Methods
      ##
      
      ## Set location of base tempdir
      def self.cache_dir=
        
        
        
      end
      
      ## Location of base tempdir
      def self.cache_dir
        
        
        
      end
      
      ## Forcibly set environment (not normally needed)
      def self.environment=
      
        
      end
      
      ## Send progress information to STDOUT
      def self.noisy=
      
        
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
            source.metadata      = data['metadata']
            source.certificate   = data['certificate']
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
      
      def cached_metadata_file
        
      end
      
      def cached_certificate_file
        
      end
      
      ## Work out if we are in production or not by snooping on environment
      ## This is a magical bodge to make :auto option in #load vaguely useful
      def Source.in_production?

        return true if Source.environment == :production
        return true if defined? Rails and Rails.env.production? 
        return true if defined? Rack and defined? RACK_ENV and RACK_ENV == 'production'
        
      end
    
    end
  end
end