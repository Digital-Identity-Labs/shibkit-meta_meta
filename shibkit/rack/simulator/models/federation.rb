require 'shibkit/rack/simulator/models/base'
require 'shibkit/metameta'

module Shibkit
  module Rack
    class Simulator
      module Model
        class Federation < Base
        
          setup_storage
          
          ## 
          attr_accessor :display_name
          attr_accessor :uri
          attr_accessor :metadata_id
          attr_accessor :idps         
          
          def set_defaults
            
            @idps = []
            
          end
          
          ## Copy data from a suitable MetaMeta object
          def from_metadata(mm_fed)
             
            @display_name   = mm_fed.display_name   if mm_fed.display_name
            @uri            = mm_fed.federation_uri if mm_fed.federation_uri
            @metadata_id    = mm_fed.metadata_id    if mm_fed.metadata_id
                               
          end
          
          def Federation.load_records(metadata_sources=Federation.config.federation_metadata)
                    
            ## Metadata stored here for a bit...
            mm = Shibkit::MetaMeta.new
            
            ## Try to load the prepared cached data for speed
            begin
              
              mm.load_cache_file(Federation.config.sim_metadata_cache_file)
              
            ## If cached data unavailable load metadata files and process
            rescue
              
              ## Some logging in debug mode
              # ...
              
              ## Configure metadata sources
              metadata_sources.each_pair {|name, file| mm.add_source(name, file) }                  
              
              ## Refresh/reload from metadata sources
              mm.refresh
              
            end
            
            begin
              
            ## Each federation object in metadata
            mm.federations.each do |fed_metadata|
 
              federation = Shibkit::Rack::Simulator::Model::Federation.create do |f|
                  
                 f.from_metadata(fed_metadata)

                 ## Each IDP for this federation too
                 fed_metadata.entities.each do |entity_metadata|

                   idp = Shibkit::Rack::Simulator::Model::IDPService.create
                   idp.from_metadata(entity_metadata)
                   
 
                   dir = Shibkit::Rack::Simulator::Model::Directory.create
                     
                   dir.display_name = entity_metadata.organisation.display_name + " User Directory"
                   dir.idp  = idp
                   dir.load_accounts(Federation.config.sim_users_file)
                     
                   idp.directory = dir
                   
                   f.idps << idp

                 end
                
              end
                          
            end
            
            rescue => oops
              
              puts "Error loading metadata into Shibkit::Simulator!"
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
  