module Shibkit
  module Rack
    class Simulator
      module Model
        module Federation
       
          ## Easy access to Shibkit's configuration settings
          include Shibkit::Configured

          ## Is the request user_id or username valid? Returns valid user_id or nil
          def authenticate(user_id, credential)



          end

          ## Returns details for user
          def lookup_user(user_id)

          end

          ## Returns list of all users as list
          def users

          end

          ## List all federations
          def federations

          end

          ## List all organisations
          def organisations

          end

          ## Returns all users in a particular organisation
          def users_in_organisation(organisation_id)

          end

          ## Returns all organisations in federation
          def organisations_in_federation(federation_id)

          end

        end
      end
    end
  end
end
  