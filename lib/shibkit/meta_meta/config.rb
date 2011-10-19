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
          
      include Singleton
      
      ## Location of default real sources list (contains real-world federation details)
      REAL_SOURCES_FILE = "#{::File.dirname(__FILE__)}/data/real_sources.yml"
      
      ## Location of default mock sources list (contains small fictional federations)
      DEV_SOURCES_FILE  = "#{::File.dirname(__FILE__)}/data/dev_sources.yml"
      
      ##
      def initialize(&block)
        
        @environment   = :development
        
        @logger                 = ::Logger.new(STDOUT)
        @logger.level           = ::Logger::INFO
        @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
        @logger.formatter       = proc { |severity, datetime, progname, msg| "#{datetime}: #{severity} #{msg}\n" }
        @logger.progname        = "MetaMeta"
        
        @download_log_file  = nil
        
        @quickload = false
        
        @sources_file  = :auto
        
        @selected_federation_uris = []
        
        @download_cache_options = {
          :default_ttl => 60*60*2,
          :verbose     => false,
          :metastore   => Addressable::URI.convert_path(File.join(cache_root, 'meta')).to_s,
          :entitystore => Addressable::URI.convert_path(File.join(cache_root, 'body')).to_s            
        }
        
        ## Execute block if passed one      
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
          file_path = self.in_production? ? REAL_SOURCES_FILE : DEV_SOURCES_FILE
        when :dev, :test
          file_path = DEV_SOURCES_FILE
        when :real, :prod, :production
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
        
        return @purge_xml || false
        
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

        @selected_federation_uris ||= []
        
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
        
        return @auto_tag || false
        
      end
      
      ## 
      def merge_primary_tags=(bool)
        
         @merge_primary_tags = bool ? true : false
        
      end
      
      ## 
      def merge_primary_tags?
        
        return @merge_primary_tags || true
        
      end
          
      ## Forcibly set environment (not normally needed)
      ## @return [String]
      def environment=(environ)

        @environment = environ

      end

      ## Forcibly set environment (not normally needed)
      ## @return [String]
      def environment

        return @environment || 'production'

      end

      ## Options to set how remote files are cached and expired
      ## @param [Hash] Rack::Cache compatible hash of options
      ## @see http://rtomayko.github.com/rack-cache/ Rack::Cache for more information
      def download_cache_options=(options)
        
        if download_cache_options
          @download_cache_options.merge!(options) 
        else
          @download_cache_options = @options
        end  
        
      end      

      ## Returns hash of options to set how remote files are cached and expired
      def download_cache_options
        
        return @download_cache_options

      end
      
      
      ## Work out if we are in production or not by snooping on environment
      ## This is a magical bodge to make :auto option in #load vaguely useful
      def in_production?
        
        return true # Obviously temporary until the dev metadata is fixed
        
        return true if self.environment == :production
        return true if defined? Rails and Rails.env.production? 
        return true if defined? Rack and defined? RACK_ENV and RACK_ENV == 'production'
        
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

       return 1
        
      end
      
      ## 
      def platform

       return [RUBY_VERSION, RUBY_PLATFORM, RUBY_RELEASE_DATE].join(':')
        
      end
      
      private
      
      ## Are we on a POSIX standard system or on MS-DOS/Windows, etc?
      def sensible_os?

        return ::Config::CONFIG['host_os'] =~ /mswin|mingw/ ? false : true

      end


    end
  end
end
