module Shibkit
  
  require 'digest/md5'
  require 'digest/sha1'
  require 'base64'
  
  
  class DataTools
  
    ## Unique identifiers for user Shibboleth SP session, etcs
    def DataTools.xsid
    
      ## Reset seed of random sequence using current time
      srand
    
      ## Like an MD5sum of nothing in particular
      return '_' + rand(0xffffffffffffffffffffffffffffffff).to_s(16)
    
    end
    
    ## Generate an eduPersonTargetedID identifier
    def DataTools.eptid_user_id(source_id, sp_id, salt=nil, type=:computed)
      
      ## We just want to create the user id part
      tid = ""
      
      ## We really need a salt to be consistent, so make one up if not provided
      salt ||= Digest::SHA1.hexdigest(idp_id)
      
      ## Create the string
      case type
      when :computed        
        tid = Base64.encode64(Digest::SHA1.digest([source_id, sp_id ,salt].join('!'))).chomp
      when :random
        tid = UUID.new.generate # <- This will not persist here... get from user record!
      else
        raise "Unknown targeted_id/persistent_id type"
      end
      
      return tid
      
    end
    
    ## Create a relatively accurate targeted id/persistent id
    def DataTools.persistent_id(source_id, sp_id, idp_id, salt=nil, type=:computed)
      
      ## Generate a base user id
      user_id = Shibkit::DataTools.eptid_user_id(source_id, sp_id, salt, type)

      return [idp_id,sp_id,user_id].join('!')
      
    end
    
    ## Generates one of two different formats for targetted ids
    def DataTools.targeted_id(source_id, sp_id, idp_id, salt=nil, type=:computed)
      
      ## Generate a base user id
      user_id = DataTools.eptid_user_id(source_id, sp_id, salt, type)
      
      return [user_id,idp_id].join('@')
      
    end
  
  end
end