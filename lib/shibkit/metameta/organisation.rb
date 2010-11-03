module Shibkit
  class MetaMeta

    ## Class to represent the metadata of the organisation owning a Shibboleth entity
    class Organisation
      
      ## The name identifier for the organisation
      attr_accessor :name
      
      ## The human-readable display name for the organisation
      attr_accessor :display_name
      
      ## The homepage URL for the organisation
      attr_accessor :url
      
    end

    end
  end
  