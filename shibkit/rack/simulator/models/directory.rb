

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
          attr_accessor :accounts
                  
          
          def set_defaults
            
            @idp      = nil
            @accounts = []
            @type     = :ldap
            @principal_attribute = 'uid'
            
          end
          
          ## Is the request user_id or username valid? Returns valid user_id or nil
          def authenticate(username, credential) 

            ## Hardcoded to passwords at the moment...
            return nil unless username.to_s.downcase == credential.to_s.downcase
            
            result = @accounts[username.downcase]
            
            return nil unless result

            return result.id

          end

          ## Returns details for user
          def lookup_account(username)

            return @accounts[username.downcase]

          end
          
          ## Lists example credentials
          def example_accounts
            
            credentials = @accounts.values.slice(0,5)
            
            return credentials
            
          end
          
          ## Shibsim base location of the Directory
          def service_base_path
           
            return config.sim_dir_base_path + idp.id.to_s

          end
          
          ## Shib sim location of this directory, but with trailing /
          def service_root_path
            
            return service_base_path + '/'

          end
          
          ## Location of a user record
          def user_record_path(user)
            
            url_id = nil
            
            case user.class
            when Shibkit::Rack::Simulator::Model::Account
              url_id = user.id.to_s
            else 
              url_id = user.to_i.to_s  
            end
            
            return service_root_path + "user/" + url_id

          end
          
          def load_accounts(source_file = config.sim_users_file)
  
            raise "No suitable IDP has been defined" unless self.idp and self.idp.uri
            
            ## Try to get list of user details under the IDP's entity URI
            raw_records = Directory.import_users_file(source_file, idp.uri)
            
            ## If that doesn't provide any data, try to use the default templates
            unless raw_records and raw_records.size > 0
              
              ## Load the default list instead
              raw_records = Directory.import_users_file(source_file, "default")
              
              ## Process to substitute template values
              raw_records.each do |record|

                record.each_pair do |k,v|

                  if v.respond_to?(:each) 

                      v.each do |vv|

                        vv.gsub!('$SCOPE', idp.scope)
                        vv.gsub!('$ORG',   idp.display_name || "The Organisation")

                        
                      end
                    
                  else
                
                    v.gsub!('$SCOPE', idp.scope)
                    v.gsub!('$ORG',   idp.display_name)

                  end
                
                end
              end         
            end
            
            @accounts = Hash.new       
            indexed_records = Hash.new
                       
            raw_records.each do |raw|
              
              principal = raw[principal_attribute].to_s.downcase
              raise "User is missing a principal/username: \n #{raw.to_yaml}" if principal.empty?
              
              ## Insert record into hash using its principal/username as key
              indexed_records[principal] = raw
              
            end

            indexed_records.each_pair do |principal, user_record|
              
              account = Account.create do |a|
                
                a.attributes = user_record
                a.principal  = principal

              end
              
              @accounts[principal] = account
              
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
            
            ## Return a *copy*, leave the cache unchanged to prevent template overwrites
            return Marshal.load(Marshal.dump(raw_records))
            
          end
          
          private
 
 
        end
      end
    end
  end
end





  

