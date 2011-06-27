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