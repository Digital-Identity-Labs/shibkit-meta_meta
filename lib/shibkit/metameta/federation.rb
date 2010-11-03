module Shibkit
  class MetaMeta

    ## Class to represent a Shibboleth Federation or collection of local metadata
    ## 
    class Federation
      
      ## The human-readable display name of the Federation or collection of metadata
      attr_accessor :display_name
      
      ## The unique ID of the federation document (probably time/version based)
      attr_accessor :metadata_id
      
      ## The URI name of the federation (may be missing for local collections)
      attr_accessor :federation_uri
      
      ## Expiry date of the published metadata file
      attr_accessor :valid_until
      
      ## Array of entities within the federation or metadata collection
      attr_accessor :entities  
      
      ## Time the Federation metadata was parsed
      attr_reader :read_at
      
      ## 
      def initialize
      
        @read_at = Time.new
      
      end
      
    end


    end
  end
  