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

    ## Class to represent technical or suppor contact details for an entity
    class Contact
      
      ## The given name of the contact (often the entire name is here)
      attr_accessor :givenname
      
      ## The surname of the contact
      attr_accessor :surname
      
      ## The email address of the contact formatted as a mailto: URL
      attr_accessor :email_url
      
      ## The category of the contact (support or technical)
      attr_accessor :category   
      
      ## Usually both the surname and givenname of the contact
      def display_name
      
        return [givenname, surname].join(' ')
      
      end
      
    end

    end
  end
  