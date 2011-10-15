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
          
          file_path = ::File.expand_path(filename)
          raise "Can't access file #{file_path}!" unless ::File.exists?(file_path) and
            ::File.readable?(file_path)

          file = Tempfile.new(Time.new.to_i.to_s) 
          open(file_path, 'w') { |f| f << http_response.to_s }

          return file

        end

        ## Copy a remote file into the working directory, also caching it for next update
        def fetch_remote(url)

          self.class.init_caches 
 
          http_response = RestClient.get(url)

          file = Tempfile.new(Time.new.to_i.to_s)
          open(file.path, 'w') { |f| f << http_response.to_s }

          return file

        end
        
        ## Class methods to mixin to including class
        module CDClassMethods
          
          ##
          ## Class Methods
          ##
        
          public
                    
          ## Create the web cache 
          def init_caches

            @initialised_caches ||= false

            ## Because these long class names are pain to keep typing
            config = ::Shibkit::MetaMeta.config
          
            unless @initialised_caches
              

              ## JIT loading of the Cache module so we can set options first
              RestClient.enable Rack::Cache, config.download_cache_options

              ## Allow user to write log of all downloads in a standard format
              if config.downloads_logger

                RestClient.enable Rack::CommonLogger, config.downloads_logger

              else

                RestClient.disable Rack::CommonLogger

              end


              @initialised_caches = true

            end
            
            ## Helps if the locations actually exist, of course.
            FileUtils.mkdir_p File.join(config.cache_root, 'meta')
            FileUtils.mkdir_p File.join(config.cache_root, 'body')
            
          end
        
        
        
        
        end
      end
    end
  end
end
 