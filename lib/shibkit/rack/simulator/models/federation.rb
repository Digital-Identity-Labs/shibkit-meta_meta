require 'shibkit/rack/simulator/models/base'
require 'shibkit/metameta'

module Shibkit
  module Rack
    class Simulator
      module Model
        class Federation < SuperModel::Base
        
          include SuperModel::RandomID
        
          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
    
          ## 
          attributes              :display_name, :uri, :metadata_id, :idps         
          validates_presence_of   :display_name, :uri
          validates_uniqueness_of :uri, :message => "Detected a conflicting federation URI!"
          has_many :idps, :class_name => "Shibkit::Rack::Simulator::Model::IDPService"
        
          ## Copy data from a suitable MetaMeta object
          def from_metadata(mm_fed)
            
            display_name   = mm_fed.display_name   if mm_fed.display_name
            uri            = mm_fed.federation_uri if mm_fed.federation_uri
            metadata_id    = mm_fed.metadata_id    if mm_fed.metadata_id
                              
          end
          
          def Federation.load_records(metadata_sources=config.federation_metadata)
                    
            ## Metadata stored here for a bit...
            mm = Shibkit::MetaMeta.new
            
            ## Try to load the prepared cached data for speed
            begin
              
              mm.load_cache_file(config.sim_metadata_cache_file)
              
            ## If cached data unavailable load metadata files and process
            rescue
              
              ## Configure metadata sources
              metadata_sources.each_pair {|name, file| mm.add_source(name, file) }                  
              
              ## Refresh/reload from metadata sources
              mm.refresh
              
            end
            
            begin
              
            ## Each federation object in metadata
            mm.federations.each do |fed_metadata|
              
              puts "GGGG"
              puts fed_metadata.inspect
              
              federation = Shibkit::Rack::Simulator::Model::Federation.find_or_create_by_uri do |f|
                
                  puts "VVVV"
                  puts f.inspect
                
                f.from_metadata(fed_metadata)
                
              
                
              end
              
              puts "XXXXXX"
              puts federation.inspect
                            
              ## Each IDP for this federation too
              fed_metadata.entities.each do |entity_metadata|
                
                puts "FFFF"
                puts entity_metadata
                
                idp = Shibkit::Rack::Simulator::Model::IDPService.find_or_create_by_uri(entity_metadata.entity_uri) do |i|
                
                  i.from_metadata(entity_metadata)
                
                end
                
                federation.idps << idp
                
              end

            end
            
            rescue => oops
              
              puts "ARSE"
              puts oops
              puts oops.inspect
              raise
              
            end
            
          end
          
        end
      end
    end
  end
end
  