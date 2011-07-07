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
require 'open-uri'

require 'shibkit/meta_meta/metadata_item'
require 'shibkit/meta_meta/contact'
require 'shibkit/meta_meta/source'
require 'shibkit/meta_meta/entity'
require 'shibkit/meta_meta/federation'
require 'shibkit/meta_meta/organisation'

module Shibkit
  
  ## Simple library to parse Shibboleth metadata files into Ruby objects
  class MetaMeta
        
    attr_accessor :sources
    attr_accessor :source_file
    attr_reader   :federations    
        
    ## New default object
    def initialize(&block)
    
      @source_file = :auto
      @sources     = Array.new
      @all_sources = nil
      @federations = Array.new
      @read_at     = nil
      
      self.instance_eval(&block) if block
      
    end
    
    ## Convenience method to add a source by id/name from 
    def add_source(source_name)
      
      ## Load and memoize all sources in selected file
      @all_sources ||= Source.load(@source_file)
    
      self.sources << @all_sources[source_name.downcase.to_s.strip] 
    
    end
    
    ## Downloads and reprocesses metadata files  
    def refresh(force=false)
      
      @sources.each do |source|
      
        #@federations << MetaMeta.parse(source)
        #@read_at     = Time.new
        
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
    
    def federations
  
      if @federations.empty?

        parse_sources
        
      end
      
      return @federations
      
    end
    
    ## Parses sources and returns an array of federation object
    def parse_sources

      raise "MetaMeta sources are not an Array! (Should not be a #{sources.class})" unless
        sources.kind_of? Array
      
      @federations ||= Hash.new
      
      sources.each do |source|
        
        fx = source.parse

        federation = Federation.new(fx) do |f|
                    
          ## Extract basic 'federation' information 
          f.display_name   = source.name
        
        end

        @federations << federation
        
      end
      
      return @federations
         
    end
         
    private
    
    # ...
 
  end
end
