module Shibkit
  class MetaMeta

    ## A few simple utility functions for slurping data from XML
    ## 
    module XPathChores

      private 

      ## Return array of element contents when given xpath
      def extract_simple_list(xpath)
  
        results = Array.new
  
        @xml.xpath(xpath).each do |ix|
    
          results << ix.content.to_s.strip
    
        end
  
        return results
  
      end 
      
      ## Language-mapped Hash
      def extract_lang_map_of_strings(xpath)
  
        results = Hash.new

        @xml.xpath(xpath).each do |ix|

          lang = ix['lang'] || :en
          results[lang.to_sym] = ix.content.strip
      
        end
        
        return results
  
      end

      ## Language-mapped Hash of string lists
      def extract_lang_map_of_string_lists(xpath)
        
        results = Hash.new
  
        @xml.xpath(xpath).each do |ix|
  
          items = ix.content.split(' ')
          items.each { |item| item.gsub!('+',' ') }
          
          lang = ix['lang'] || :en
          results[lang.to_sym] = items

        end
  
        return results
  
      end
      
      ## Language-mapped Hash
      def extract_lang_map_of_objects(xpath, req_class)
  
        results = Hash.new
  
        @xml.xpath(xpath).each do |ix|
          
          case req_class.respond_to?(:filter)
          when true
            obj = req_class.new(ix).filter
          when false
            obj = req_class.new(ix)
          end
          
          if obj
            lang = ix['lang'] || :en
            results[lang] ||= Array.new
            results[lang] << obj
          end
          
        end
  
        return results
  
      end
      
    end
  end
end
