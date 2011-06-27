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

require 'rubygems'
require 'nokogiri'
require 'yaml'

require 'shibkit/meta_meta/metadata'
require 'shibkit/meta_meta/contact'
require 'shibkit/meta_meta/source'
require 'shibkit/meta_meta/entity'
require 'shibkit/meta_meta/federation'
require 'shibkit/meta_meta/organisation'

module Shibkit
  
  ## Simple library to parse Shibboleth metadata files into Ruby objects
  class MetaMeta
        
    attr_accessor :sources
    attr_accessor :federations
        
    ## New default object
    def initialize(&block)
    
      @sources     = Array.new
      @federations = Array.new
      @read_at     = nil
      
      self.instance_eval(&block) if block
    
    end
    
    ## Convenience method to add a source
    def add_source(name, file, refresh=360, cache=true)
    
      self.sources << Source.new do |s|
        
        s.name    = name
        s.file    = file
        s.refresh = refresh
        s.cache   = cache
        
      end
    
    end
    
    ## Downloads and reprocesses metadata files  
    def refresh(force=false)
      
      @sources.each do |source|
      
        @federations << MetaMeta.parse(source)
        @read_at     = Time.new
        
      end
      
    end 
    
    ## Loads federation metadata contents 
    def load_cache_file(file_or_url)
        
        @federations = YAML::load(File.open(file_or_url))
        
        return true
        
    end
    
    ## Save entity data into a YAML file. 
    def save_cache_file(file)
        
      ## Will *not* overwrite the example/default file in gem! TODO: this code is awful.
      gem_data_path = "#{::File.dirname(__FILE__)}/data"
      if file.include? gem_data_path 
        raise "Attempt to overwrite gem's default metadata cache! Please specify your own file to save cache in"
      end
        
      ## Write the YAML to disk
      File.open(file, 'w') do |out|
        YAML.dump(@federations, out)
      end
        
      return true
        
    end    
    
    ## Parses a string containing metadata XML and returns a federation object
    def MetaMeta.parse(source)
      
      xml_text = source.content
      
      federation = Federation.new(xml_text) do |f|
      
        ## Extract basic 'federation' information 
        f.display_name   = source.name
        
      end
         
      return federation
      
    end
    
    private
    
 
  end
end
