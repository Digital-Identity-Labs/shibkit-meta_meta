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
    
    module Mixin
    
      ## A few simple utility functions for slurping data from XML
      ## 
      module CachedDownloads

        require 'rest_client'
        require 'restclient/components'
        require 'rack/cache'
        require 'rack/commonlogger'
        require 'rbconfig'
        require 'tempfile'
        require 'addressable/uri'
        require 'fileutils'
        
        ## Automatically add class methods to the including class
        def self.included(receiver)

          receiver.extend(CDClassMethods)
        
        end

        ## Copy a filesystem file into the working directory (slower but safer)  
        def fetch_local(filename)
          
          return unless filename
          
          file_path = ::File.absolute_path(filename)
          raise unless ::File.exists?(file_path) and ::File.readable?(file_path)

          file = Tempfile.new(uuid)
          open(file_path, 'w') { |f| f << http_response.to_s }

          return file

        end

        ## Copy a remote file into the working directory, also caching it for next update
        def fetch_remote(url)

          self.class.init_caches 
 
          http_response = RestClient.get(url)

          file = Tempfile.new(uuid)
          open(file.path, 'w') { |f| f << http_response.to_s }

          return file

        end
        
        ## Class methods to mixin to including class
        module CDClassMethods
          
          ##
          ## Class Methods
          ##
        
          public
        
          ## Options to set how remote files are cached and expired
          ## @param [Hash] Rack::Cache compatible hash of options
          ## @see http://rtomayko.github.com/rack-cache/ Rack::Cache for more information
          def cache_options=(options)

            @cache_options.merge(options) if cache_options and options.size > 0

          end      

          #protected

          ## Returns hash of options to set how remote files are cached and expired
          def cache_options

            unless @cache_options 

              cache_root = Source.cache_root

              @cache_options = {
                :verbose     => self.respond_to?(:verbose?) ? self.verbose? : false,
                :metastore   => Addressable::URI.convert_path(File.join(cache_root, 'meta')).to_s,
                :entitystore => Addressable::URI.convert_path(File.join(cache_root, 'body')).to_s            
              }

            end

            return @cache_options

          end
          
          
          ## Forcibly set environment (not normally needed)
          ## @return [String]
          def config=(config_opts)

            @auto_refresh = config[:auto_refresh] if config[:auto_refresh]
            @environment  = config[:environment].to_sym if config[:environment]
            @verbose      = config[:verbose]      if config[:verbose]
            @logfile      = config[:logfile]      if config[:logfile] 

            return true

          end

          ## Forcibly set environment (not normally needed)
          ## @return [String]
          def environment

            return @environment || 'production'

          end

          ## Send progress information to STDOUT
          ## @return [String]
          def log_file

            return @log_file || nil

          end

          ## Work out if we are in production or not by snooping on environment
          ## This is a magical bodge to make :auto option in #load vaguely useful
          def in_production?

            return true if self.environment == :production
            return true if defined? Rails and Rails.env.production? 
            return true if defined? Rack and defined? RACK_ENV and RACK_ENV == 'production'

          end

          ## Are we on a POSIX standard system or on MS-DOS/Windows, etc?
          def sensible_os?

            return Config::CONFIG['host_os'] =~ /mswin|mingw/ ? false : true

          end

          ## Calculate the filesystem path to store the web cache
          def cache_root

            tmp_dir  = sensible_os? ? '/tmp' : ENV['TEMP']
            base_dir = File.join(tmp_dir, 'skmm-cache')

            return base_dir

          end
          
          
          ## Send progress information to STDOUT
          ## @return [String]
          def verbose?

           return @verbose || false

          end

          ## Send progress information to STDOUT
          ## @return [String]
          def auto_refresh?

           return @auto_refresh || true

          end

          
          ## Create the web cache 
          def init_caches

            @initialised_caches ||= false

            unless @initialised_caches

              ## JIT loading of the Cache module so we ca set options first
              RestClient.enable Rack::Cache, Source.cache_options

              ## Allow user to write log of all downloads in a standard format
              if self.class.respond_to?(:log_file) and self.class.log_file

                RestClient.enable Rack::CommonLogger, self.class.log_file

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
  end
end
 