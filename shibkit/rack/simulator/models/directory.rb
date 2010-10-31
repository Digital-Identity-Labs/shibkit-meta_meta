require 'supermodel'

module Shibkit
  module Rack
    class Simulator
      module Model
        class Directory
          
          ## Easy access to Shibkit's configuration settings
          include Shibkit::Configured
          
          ## Is the request user_id or username valid? Returns valid user_id or nil
          def authenticate(username, credential=nil)

          

          end

          ## Returns details for user
          def lookup_user(user_id)

          end
          
          ## Returns list of all users as list
          def users
          
          end

          ## Returns the directory's organisation
          def organisation
          
          
          
          end
         
          private
          
          ## Provide user data for chooser and header injection
          def Directory.load_user_data

            unless @users && @orgtree

              @users   = Hash.new
              @orgtree = Hash.new 

              fixture_data = YAML.load_file(config.sim_users_file )

              fixture_data.each_pair do |label, record| 

                record['shibsim_label'] = label.to_s.strip
                rid  = record['id'].to_s
                rorg = record['organisation'].to_s.strip

                ## Salt to use is based on org name
                record['idp_salt'] = Digest::SHA1.digest(rorg).chomp # TODO: make configurable

                @users[rid]    =   record        
                @orgtree[rorg] ||= Array.new

                @orgtree[rorg] <<  record 

              end

            end

          end
          
          ## Is the requested user valid?
          def user_details_ok?(user_details)

            return true if user_details and user_details.kind_of?(Hash) and
                user_details.size > 1 

            return false

          end
          
          ## Load data
          load_user_data
          
          ########## Hmmm line
          
          ## Munge the data in attributes to match Shib/SAML expectations
          def process_attribute_data(user_details)

            munged_data = user_details.dup

            ## Call out to filter (this is monkey patched by shibsim_filter.rb)
            munged_data = user_record_filter(munged_data)

            return munged_data

          end
          
          ## Add the filter mixin if it exists
          def load_filter_mixin

            eval "extend #{config.sim_record_filter_module}"

          end

          def check_state

            raise "No user data!" unless @users.size > 0 
            raise "No organisation labels!" unless @orgtree.size > 0

          end
          
        end
      end
    end
  end
end





  

