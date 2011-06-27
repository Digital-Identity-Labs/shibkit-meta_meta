
module Shibkit
  module Rack
    class Simulator
      module Model
        class Base
          
          require 'shibkit/rack/base/mixins/http_utils'
          
          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
          
          include Shibkit::Rack::Base::Mixin::HTTPUtils
          
          attr_accessor :id
          
          ## New default object
          def initialize(&block)
            
            set_defaults
            before_create
            
            @id = self.class.generate_id unless @id
            
            self.instance_eval(&block) if block
            
            after_create
            
          end 

          ## Save to hash
          def save
            
            before_save
            
            self.class.store self
                       
            after_save
            
            return self
                  
          end

          ## Save to hash
          def delete
            
            self.class.unstore self
                        
          end

          ## New and save to hash
          def self.create(*params, &block)
            
            new_item = new(*params, &block) 
            
            new_item.save
            
            return new_item
            
          end
          
          ## Find a single record by id (no search! Use .collect)
          def self.find(object_id)

            return @saved_records[object_id.to_s]
          
          end
          
          ## List all records
          def self.all
          
            return @saved_records.values
          
          end
          
          ## List all records
          def self.all_indexed
          
            return @saved_records
          
          end
          
          private
          
          def before_create
            
            
          end
          
          def after_create
            
          end
          
          def before_save
          
          end
          
          def after_save
          
          end
          
          def set_defaults
          
            
          
          end
          
          ## Save to class instance variable
          def self.store(item)
            
            @saved_records[item.id.to_s] = item
          
          end
          
          ## Save to class instance variable
          def self.unstore(item)
            
            @saved_records[item.id.to_s].delete
            
            
          end
          
          ## Simple automatic IDs
          def self.generate_id
            
            @nid ||= 0
            @nid = @nid + 1
            
            return @nid
          
          end
          
          def self.setup_storage
            
            ## Class object variable to store id-keyed hash of objects
            @saved_records = Hash.new
            @nid   = 0
            
          end
          
          setup_storage
          
        end
      end
    end
  end
end
