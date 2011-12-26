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
  
    class Config

      require 'logger'
      require 'rbconfig'
      require 'tempfile'
      require 'addressable/uri'
      require 'fileutils'
      require 'singleton'
      require 'rbconfig'
      
      include Singleton
      
      ## Location of default real sources list (contains real-world federation details)
      REAL_SOURCES_FILE = "#{::File.dirname(__FILE__)}/data/real_sources.yml"
      
      ## Location of default mock sources list (contains small fictional federations)
      DEV_SOURCES_FILE  = "#{::File.dirname(__FILE__)}/data/real_sources.yml"
      
      ## Location of default test sources list # TODO
      TEST_SOURCES_FILE  = "#{::File.dirname(__FILE__)}/data/real_sources.yml"
      
      ##
      def initialize(&block)
 
        @logger                 = ::Logger.new(STDOUT)
        @logger.level           = ::Logger::INFO
        @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
        @logger.formatter       = proc { |severity, datetime, progname, msg| "#{datetime}: #{severity} #{msg}\n" }
        @logger.progname        = "MetaMeta"
        
        @download_cache_options = Hash.new
        @sources_file  = :auto
        
        @selected_federation_uris = []

        ## Execute block if passed one  ## Does not get one. Needs a work around, eventually.    
        instance_eval(&block) if block
        
      end
      
      def configure(&block)
        
        ## Execute block if passed one      
        self.instance_eval(&block) if block
        
      end
      
      ##
      def sources_file=(file_path)
      
        @sources_file = file_path
        
      end
      
      ##
      def sources_file
        
        @sources_file ||= :auto
        
        case @sources_file
        when :auto
          #file_path = self.in_production? ? REAL_SOURCES_FILE : DEV_SOURCES_FILE
          file_path = REAL_SOURCES_FILE
        when :dev, :development
          file_path = DEV_SOURCES_FILE
        when :test, :testing
          file_path = TEST_SOURCES_FILE
        when :real, :prod, :production, :all, :full
          file_path = REAL_SOURCES_FILE
        else
          file_path = @sources_file
        end
        
        return file_path
        
      end
      
      ## Purge all XML data from object after creating object
      def purge_xml=(bool)
        
         @purge_xml = bool ? true : false
        
      end
      
      ## Should all XML be purged from objects after creation?
      def purge_xml?
        
        return @purge_xml.nil? ? true : @purge_xml
        
      end
      
      ## Store source XML alongside the parsed XML
      def remember_source_xml=(bool)
        
         @remember_source_xml = bool ? true : false
        
      end
      
      ## Store source XML alongside the parsed XML
      def remember_source_xml?
        
        return @remember_source_xml.nil? ? false : @remember_source_xml
        
      end
      
      def smartcache_expiry=(seconds)
        
        @smartcache_expiry = seconds.to_i
      
      end
      
      def smartcache_expiry
        
       return @smartcache_expiry || 60*60
      
      end
      
      def smartcache_active=(bool)
        
         @smartcache_active = bool ? true : false
        
      end
      
      def smartcache_active?
        
         return @smartcache_active.nil? ? true : @smartcache_active
        
      end
      
      def smartcache_object_file 
      
        return File.join(cache_root, 'smartcache.marshal')
      
      end
      
      def smartcache_info_file 
      
        return File.join(cache_root, 'smartcache.yml')
      
      end
      
      def verbose_downloads=(bool)

       @verbose = bool ? true : false
       self.download_cache_options = { :verbose => @verbose }

      end

      def verbose_downloads?
      
       return @verbose.nil? ? false : @verbose 

      end
      
      def cache_fallback_ttl=(seconds)
        
        @cache_fallback_ttl = seconds.to_i
        self.download_cache_options = { :default_ttl => @cache_fallback_ttl }
        
      end

      def cache_fallback_ttl
        
        return @cache_fallback_ttl.nil? ? 7200 : @cache_fallback_ttl 
      
      end
            
      ## Set main logger
      def logger=(logger)
        
        @logger = logger

      end
      
      ## Returns current main logger
      def logger

        return @logger

      end
      
      ##
      def downloads_logger=(logger)

        return @downloads_logger = logger

      end
      
      ##  
      def downloads_logger

        return @downloads_logger || nil

      end

      ## Load a metadata sources file automatically (true or false)
      def autoload=(setting)

        @autoload = setting ? true : false

      end

      ## Should metadata sources and objects be loaded automatically? Normally, yes.
      def autoload?

        return true unless defined? @autoload
        return @autoload 

      end
      
      def metadata_namespaces=(hash)
        
        @metadata_namespaces = hash
                
      end
      
      ## Return all XML namespaces needed/used by metadata
      def metadata_namespaces
        
        ## Possible to automate this if I bodge the XML processing less...?
        ## This is not a good solution, it would be better if Nokogiri was allowed
        ## to sort this out itself.
        
        @metadata_namespaces ||= {
          'ukfedlabel' => 'http://ukfederation.org.uk/2006/11/label',
          'elab'       => 'http://eduserv.org.uk/labels',
          'wayf'       => 'http://sdss.ac.uk/2006/06/WAYF',
          'mdui'       => 'urn:oasis:names:tc:SAML:metadata:ui',
          'saml'       => 'urn:oasis:names:tc:SAML:2.0:assertion',
          'md'         => 'urn:oasis:names:tc:SAML:2.0:metadata',
           nil         => 'urn:oasis:names:tc:SAML:2.0:metadata',
          'shibmd'     => 'urn:mace:shibboleth:metadata:1.0'
        }
        
        return @metadata_namespaces
        
      end
      
      ## 
      def selected_groups=(*list)
        
        @selected_groups = [list].flatten 
        @selected_groups = [] if @selected_groups.include? :all
        
      end

      ## 
      def selected_groups

        return @selected_groups || []

      end
      
      ## Only use these federations/sources even if know about 100s - works on 
      ## various functions (loading, processing and listing *after* it is set)
      def only_use(selection)

        @selected_federation_uris = []
        
        case selection
        when String
          @selected_federation_uris << selection
        when Array
          @selected_federation_uris.concat(selection)
        when Hash
          @selected_federation_uris.concat(selection.keys)
        when :all, :everything, nil, false
          @selected_federation_uris = []
        else
          raise "Expected federation/source selection to be single uri or array"
        end

      end 
      
      ## List of federation/collection uris
      def selected_federation_uris=(selection)

        only_use(selection)

      end
      
      ## List of federation/collection uris
      def selected_federation_uris

        return @selected_federation_uris || []

      end

      ## @return [String]
      def auto_refresh=(bool)

       @auto_refresh = bool ? true : false

      end
      
      ## @return [String]
      def auto_refresh?

       return @auto_refresh.nil? ? true : @auto_refresh

      end
      
      def can_delete=(bool)
        
        @can_delete = bool ? true : false
        
      end
      
      def can_delete?
        
        return @can_delete || false
        
      end
      
      ## 
      def auto_tag=(bool)
        
         @auto_tag = bool ? true : false
        
      end
      
      ## 
      def auto_tag?
        
        return @auto_tag.nil? ? false : @auto_tag
        
      end
      
      ## 
      def merge_primary_tags=(bool)
        
         @merge_primary_tags = bool ? true : false
        
      end
      
      ## 
      def merge_primary_tags?
        
        return @merge_primary_tags.nil? ? true : @merge_primary_tags
        
      end
          
      ## Forcibly set environment (not normally needed)
      ## @return [String]
      def environment=(environ)

        @environment = environ.to_sym

      end

      ## Forcibly set environment (not normally needed)
      ## @return [String]
      def environment

        return @environment || :development

      end

      ## Options to set how remote files are cached and expired
      ## @param [Hash] Rack::Cache compatible hash of options
      ## @see http://rtomayko.github.com/rack-cache/ Rack::Cache for more information
      def download_cache_options=(options)
        
        @download_cache_options ||= Hash.new
        
        if download_cache_options
          @download_cache_options.merge!(options) 
        else
          @download_cache_options = @options
        end  
        
      end      

      ## Returns hash of options to set how remote files are cached and expired
      def download_cache_options
        
        @download_cache_options ||= Hash.new

        return download_cache_defaults.merge(@download_cache_options).freeze

      end
      
      
      ## Work out if we are in production or not by snooping on environment
      def in_production?

        ## Use attribute rather than method so we can distinguish between default and set values
        return true  if @environment == :production
        return false if @environment == :development
        return false if @environment == :test

        if defined? Rails and Rails.respond_to? :env
          return Rails.env.production?
        end
        
        if defined? Rack and defined? RACK_ENV
          return true if RACK_ENV == 'production'
        end        
        
        return false
        
      end
      
      ## Set cache root
      def cache_root=(file_path)

        @cache_root = file_path
        
      end
      
      ## return or calculate the filesystem path to store the web cache
      def cache_root
        
        unless @cache_root 
        
          tmp_dir     = sensible_os? ? '/tmp' : ENV['TEMP']
          @cache_root = File.join(tmp_dir, 'skmm-cache')

        end

        return @cache_root

      end
      
      ## 
      def version

        return  Shibkit::MetaMeta::VERSION
        
      end
      
      ## 
      def platform

       return [RUBY_VERSION, RUBY_PLATFORM, RUBY_RELEASE_DATE].join(':')
        
      end
      
      private
      
      ## Are we on a POSIX standard system or on MS-DOS/Windows, etc?
      def sensible_os?

        return ::RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? false : true

      end
      
      ## 
      def download_cache_defaults
        
        return {
            :default_ttl => cache_fallback_ttl,
            :verbose     => verbose_downloads?,
            :metastore   => Addressable::URI.convert_path(File.join(cache_root, 'meta')).to_s,
            :entitystore => Addressable::URI.convert_path(File.join(cache_root, 'body')).to_s            
        }

      end

    end
  end
end
