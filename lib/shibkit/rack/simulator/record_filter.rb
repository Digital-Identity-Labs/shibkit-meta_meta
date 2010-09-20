####

module Shibkit
  module Rack
    class Simulator
      module RecordFilter
    
        ## Process a user's record to make resemble Shibboleth SP attributes 
        def user_record_filter(user_record)
      
          sp_key_map = {
            'username'  => 'uid',
            'email'     => 'mail',
            'name'      => 'display_name',
            'roles'     => 'affiliation',
            'id_number' => 'personalID',
            'job_title' => 'title',
            'organisation' => 'o',
            'given_name' => 'givenName',
            'family_name' => 'sn'
          }
        
          ## Replace key names with LDAP/Shibboleth style equivalents
          sp_key_map.each_pair {|old_key, new_key| user_record[new_key] = user_record[old_key] if user_record.has_key?(old_key) }

          ## Delete any data that isn't on the sp key list
          sp_keys = sp_key_map.invert
          user_record.delete_if { |key, value| sp_keys.has_key?(key) ? false : true }

          return user_record
        
        end
    
      end    
    end
  end
end