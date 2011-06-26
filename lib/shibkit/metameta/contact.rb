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
  