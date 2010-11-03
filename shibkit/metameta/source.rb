require 'open-uri'
#require 'typhoeus'

module Shibkit
  class MetaMeta

    class Source
  
      attr_accessor :name
      attr_accessor :file
      attr_accessor :refresh
      attr_accessor :cache
  
      ## New default object
      def initialize(&block)
  
        @name    = "Unknown"
        @file    = nil
        @refresh = 0
        @cache   = true
  
        self.instance_eval(&block) if block
  
      end
  
      ## Return raw source string from the file
      def content
    
        return IO.read(file)
    
      end
  
      ## Source is reachable, valid filename/URI, etc. Does not check content
      def ok?
    
        return true if File.exists?(file) and File.readable?(file) 
    
        return false
    
      end
  
    end
  end
end