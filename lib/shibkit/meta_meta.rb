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
require 'logger'
require 'fileutils'
require 'digest/sha1'

require 'shibkit/meta_meta/config'
require 'shibkit/meta_meta/metadata_item'
require 'shibkit/meta_meta/contact'
require 'shibkit/meta_meta/source'
require 'shibkit/meta_meta/entity'
require 'shibkit/meta_meta/federation'
require 'shibkit/meta_meta/organisation'

module Shibkit
  
  ## Simple library to parse Shibboleth metadata files into Ruby objects
  class MetaMeta
    
    ## 
    def self.config(&block)

      if block
        return ::Shibkit::MetaMeta::Config.instance.configure(&block)
      else
        return ::Shibkit::MetaMeta::Config.instance
      end

    end

    ## Flush out all available sources, metadata caches, etc.
    def self.reset
      
      log.info "Resetting all sources, metadata caches, etc."
      
      ## Clear the source data
      @additional_sources   = Hash.new
      @loaded_sources       = Hash.new
   
      ## Clear federation entity data
      self.flush
      
    end
    
    ## Clear all loaded entity & federation data 
    def self.flush
      
      log.info "Flushing all loaded objects"
      
      @orgs        = Array.new
      @entities    = Array.new
      @federations = Array.new
      @by_uri      = Hash.new
      
    end
    
    ## Delete all cache files
    def self.delete_all_cached_files!
      
      dir = config.cache_root
      
      if config.can_delete?
        
        log.info "Deleting all files at #{dir}..."
        FileUtils.rm_rf   dir
        FileUtils.mkdir_p dir
        
      else
        
        log.warn "Cannot delete files at #{dir} - check config settings."
        
      end
      
    end
    
    ## Convenience method to add a source from a hash or object
    def self.add_source(data)
      
      @additional_sources ||= Hash.new
      
      case data
      when Hash
        source = Source.from_hash(data)
      when ::Shibkit::MetaMeta::Source
        source = data
      else 
        raise "Expected either hash or Source object!"
      end

      log.info "Added a source for #{source.uri}"
      
      @additional_sources[source.uri] = source
      
    end

    ## Have we loaded any sources?
    def self.loaded_sources?
      
      return @loaded_sources ? true : false
      
    end
    
    ## Load sources from a YAML file
    def self.load_sources(filename=self.config.sources_file)
      
      log.info "Loading sources from disk..."
      
      @loaded_sources = Hash.new
      
      Source.load(filename).each do |source|
        
        ## More than one definition for a source is a problem 
        raise "Duplicate source for #{source.uri}!" if @loaded_sources[source.uri]
        
        @loaded_sources[source.uri] = source
        
      end 
      
    end
    
    ## Save all known sources to sources list file
    def self.save_sources(filename)
      
      log.info "Saving sources to #{filename}..."
      
      src_dump = Hash.new
      self.sources.each { |s| src_dump[s.uri] = s.to_hash }
      
      File.open(filename, 'w') { |out| YAML.dump(src_dump, out) }
        
    end
    
    ## List all sources as an array
    def self.sources
      
      if self.config.autoload? and loaded_sources.size == 0 and additional_sources.size == 0
        
        self.load_sources
      
      end
      
      all_sources_indexed = loaded_sources.merge(additional_sources)

      sources = all_sources_indexed.values

      sources = sources.sort {|a,b| a.created_at <=> b.created_at }

      if self.filtered_sources?
        
        sources = sources.select { |s| self.selected_federation_uris.include? s.uri }
      
      end

      return sources 
      
    end
        
    ## List of federation/collection uris
    def self.selected_federation_uris
      
      return self.config.selected_federation_uris
      
    end
    
    ## Has a limited subset of federations/sources been selected?
    def self.filtered_sources?
      
      return self.selected_federation_uris.empty? ? false : true 
      
    end
    
    ## Loads federation metadata contents 
    def self.load_cache_file(file_or_url, format=:yaml)
        
        self.reset
        
        log.info "Loading object cache file from #{file_or_url} as #{format} data..."
        
        @federations = case format
        when :yaml
          YAML.load(File.open(file_or_url))
        when :marshal
          Marshal.load(File.open(file_or_url))
        else
          raise "Unexpected cache file format requested! Please use :yaml or :marshal"
        end
        
        self.entities      
        
        log.info "Processing complete."
        
        return true
        
    end
    
    ## Save entity data into a YAML file. 
    def self.save_cache_file(file_path, format=:yaml)
      
      log.info "Saving object cache file to #{file_path} as #{format} data..."
      
      ## Will *not* overwrite the example/default file in gem! TODO: this code is awful.
      gem_data_path = "#{::File.dirname(__FILE__)}/data"
      if file_path.include? gem_data_path 
        raise "Attempt to overwrite gem's default metadata cache! Please specify your own file to save cache in"
      end
      
      self.textify_xml!
      
      ## Write the YAML to disk
      File.open(file_path, 'w') do |out|
        
        case format
        when :yaml
          YAML.dump(@federations, out)
        when :marshal        
          Marshal.dump(@federations, out)
        else
          raise "Unexpected cache file format requested! Please use :yaml or :marshal"
        end
        
      end
        
      return true
        
    end
    
    ## Parses sources and returns an array of all federation object
    def self.process_sources
      
      if config.smartcache_active?
        return if self.smartcache_load
      end
      
      log.info "Processing content of sources into objects..."
      
      raise "MetaMeta sources are not an Array! (Should not be a #{self.sources.class})" unless
        self.sources.kind_of? Array
      
      self.flush
      
      self.sources.each do |source|
        
        if self.filtered_sources?
          
          next unless self.selected_federation_uris.include? source.uri
        
        end
        
        start_time = Time.new
          
        federation = source.to_federation
        
        ## Store all federations in array
        @federations << federation
        
        log.info "Loaded #{federation.entities.count} entities from #{federation} metadata file in #{Time.new - start_time} seconds."
        
        
      end
      
      ## Bodge to make sure primary ents are set, multifederation calculated, etc
      self.entities
      
      log.info "Processing complete. #{@federations.count} sets of metadata have been loaded."
      
      self.smartcache_save if config.smartcache_active?
      
      return @federations
         
    end
    
    ## Downloads and reprocesses metadata files  
    def self.refresh(force=false)
      
      log.info "Refreshing all selected federations"
      
      ## Reload source lists overwriting previous set
      self.load_sources
      
      ## Reprocess sources to create fresh set of federation and entity objects
      self.process_sources 
      
      return true
      
    end
    
    def self.stockup(force=false)
      
      if self.config.autoload?
      
        self.process_sources unless @federations
        self.process_sources if @federations.empty?
        
      end
      
    end
    
    ## Have objects been loaded from metadata?
    def self.stocked?
      
      return false unless @federations
      return false if @federations.empty? 
      
      return true
    
    end
    
    ## Return list of Federations objects (filtered if select_federations is set)
    def self.federations
      
      return [] if @federations.nil? and ! config.autoload?
      
      self.stockup
       
      if self.filtered_sources?
        
        return @federations.select { |f| self.selected_federation_uris.include? f.uri }
      
      end

      return @federations
      
    end
    
    ## All primary entities from all federations
    def self.entities
      
      return [] if @entities.nil? and ! config.autoload?
      
      ## Populate memoised array of entities if it's empty
      unless @entities and @entities.size > 0
        
        ## Array for memoising primary entities
        @entities ||= Array.new
        
        ## For keeping track of already processed entities & marking them as primary
        processed = Hash.new 
        
        self.federations.each do |f|
          
          f.entities.each do |e|
            
            ## If we've already found the primary version of the entity
            if processed[e.uri]
              
              ## Add this federation's URI to the primary
              primary = processed[e.uri]              
              primary.other_federation_uris << f.uri
              
              next
           
            end
            
            ## Mark this entity as the primary and remember it as already processed.
            e.primary = true
            processed[e.uri] = e
            
            ## Collect entity
            @entities << e 

          end

        end
        
      end
      
      return @entities
      
    end
    
    def self.orgs
      
      unless @orgs and @orgs.size > 0
        
        @orgs ||= Array.new
        
        processed = Hash.new
        
        self.entities.each do |e|
           
           org = e.organisation
           
           next unless org
           next if processed[org.druid]
           
           @orgs << org
           
          
           processed[org.druid] = true
           
        end
        
        @orgs.sort! {|a,b| a.druid <=> b.druid }
        
      end
      
      return @orgs
      
    end
    
    ## 
    def self.idps
      
      return entities.select { |e| e.idp? }
      
    end
    
    ## 
    def self.sps
      
      return entities.select { |e| e.sp? }
      
    end
    
    def self.from_uri(uri)
      
      unless @by_uri and @by_uri.size > 0
        
        @by_uri ||= Hash.new
        
        self.federations.each { |f| @by_uri[f.uri] = f unless @by_uri[f.uri] }
        self.entities.each    { |e| @by_uri[e.uri] = e unless @by_uri[e.uri] }
          
      end
      
      return @by_uri[uri]
      
    end
    
    def self.textify_xml! 
      
      @federations.each { |f| f.textify_xml(true) }
      
    end

    def self.purge_xml! 
      
      @federations.each { |f| f.purge_xml(true) }
      
    end
    
    private
    
    ## Logging 
    def self.log
    
      return ::Shibkit::MetaMeta.config.logger
      
    end
 
    private
    
    ## Access to all additional sources
    def self.additional_sources
      
      @additional_sources ||= Hash.new
      return @additional_sources
    
    end

    ## Access to all additional sources
    def self.loaded_sources
      
      @loaded_sources ||= Hash.new
      return @loaded_sources
    
    end
    
    ## 
    def self.smartcache_load
      
      log.info "Checking smartcache status..."
      
      object_file   = config.smartcache_object_file
      scmd_file     = config.smartcache_info_file
      expiry_period = config.smartcache_expiry
      
      ## Do we even have a file?
      return false unless File.exists? object_file
      return false unless File.exists? scmd_file
      
      start_time = Time.new
      
      ## Make sure the dump metadata is suitable
      info = YAML.load(File.open(scmd_file))
      
      ## Check
      cache_age = (Time.new.to_i - info[:created_at].to_i)
      return false unless cache_age < expiry_period.to_i
      
      return false unless info[:version] == config.version
      
      return false unless info[:platform] == config.platform
      
      return false unless info[:format]  == :marshal
      
      return false unless info[:object_file] == object_file
      
      return false unless info[:purge_xml]  == config.purge_xml?
      return false unless info[:source_xml] == config.remember_source_xml?
      return false unless info[:groups]     == Digest::SHA1.hexdigest(config.selected_groups.join)
      
      log.info "Smartcache is valid: loading objects..."
      
      ## If file does not exist (or is stale) and we have objects, save
      self.load_cache_file(object_file, :marshal)
      
      log.info "Loaded #{@federations.count} federations and #{@entities.count} entities from smartcache in #{Time.new - start_time} seconds."
      
      return true
      
    end
    
    ## 
    def self.smartcache_save
      
      object_file = config.smartcache_object_file
      scmd_file   = config.smartcache_info_file
      
      log.info "Saving smartcache with #{@federations.count} federations and #{@entities.count} entities..."
      
      ## Save file in fast marsh
      mkdir_p config.cache_root unless File.exists? config.cache_root
      self.save_cache_file(object_file, :marshal) 

      info = {
        :created_at  => Time.new,
        :version     => config.version,
        :platform    => config.platform,
        :object_file => object_file,
        :format      => :marshal,
        :purge_xml   => config.purge_xml?,
        :source_xml  => config.remember_source_xml?,
        :groups      => Digest::SHA1.hexdigest(config.selected_groups.join)
      }

      File.open(scmd_file, 'w') { |out| YAML.dump(info, out) }
      
      log.info "Saved smartcache."
      
      return true
      
    end

 
  end
end
