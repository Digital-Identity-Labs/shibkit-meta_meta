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
    
    module Version
        
        VERSION_FILE = "#{::File.dirname(__FILE__)}/../../../VERSION"
        
        MAJOR, MINOR, TINY = File.open(VERSION_FILE, 'r') { |file| file.gets.strip }.split('.')
        
        raise "Badly defined version!" unless MAJOR && MINOR && TINY
        
    end

    VERSION = [Version::MAJOR, Version::MINOR, Version::TINY].compact * '.'
      
  end    
end
