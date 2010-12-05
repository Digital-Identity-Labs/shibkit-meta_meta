

module Shibkit
  module Rack
    class Simulator
      module Model
        class Directory < Base
          
          ## Easy access to Shibkit's configuration settings
          include Shibkit::Configured
          
          setup_storage
          
          ## 
          attr_accessor :display_name
          attr_accessor :idp
          attr_accessor :principal_attribute
          attr_accessor :type
                  
          
          def set_defaults
            
            @idp      = nil
            @accounts = []
            @type     = :ldap
            @principal_attribute = 'uid'
            
          end

          ## Is the request user_id or username valid? Returns valid user_id or nil
          def authenticate(username, credential=nil)

          

          end

          ## Returns details for user
          def lookup_account(username)

            return @accounts[username.downcase]

          end
          
          def load_accounts(source_file = config.sim_users_file)
  
            raise "No IDP has been defined" unless self.idp and self.idp.uri
            
            raw_records = Directory.import_users_file(source_file, idp.uri)
            
            unless raw_records and raw_records.size > 0
            
              return
            
            end
            
            @accounts = Hash.new 
            
            indexed_records = Hash.new
                       
            raw_records.each do |raw|
              
              principal = raw[principal_attribute].to_s.downcase
              raise "User is missing a principal/username: \n #{raw.to_yaml}" if principal.empty?
              
              ## Insert record into hash using its principal/username as key
              indexed_records[principal] = raw
              
            end
            
            puts indexed_records.to_yaml
            
            indexed_records.each_pair do |principal, user_record|
              
              account = Account.create do |a|
                
                a.attributes = user_record
                a.principal = user_record[principal.to_s]

              end
              
              @accounts[account.principal.to_s.downcase] == account
              
            end
         
          end
          
          ## Cache loading of YAML data file so it can be re-used for each directory
          def Directory.import_users_file(source_file, directory)
            
            ## Cache this as it will be re-used for each directory
            @@imported_data ||= YAML::load( File.open(source_file) )
            
            ## Add a default list if one is missing
            # ...
            
            ## Grab the list of accounts for a particular IDP/directory
            raw_records = @@imported_data[directory] || @@imported_data[:default]
            
            
            return raw_records
            
          end
          
          private
 
 
 
        end
      end
    end
  end
end





  

