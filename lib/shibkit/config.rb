require 'singleton'
require 'ftools'

class String
  
  def to_absolute_path
     
     full_relative_path = ::File.join(::File.dirname(__FILE__), self)

      return ::File.expand_path(full_relative_path)
    
  end
  
end

module Shibkit
  

  
  class Config
    


    include Singleton
    
    CHOOSER_FORMATS  = [:simple, :ldap, :wayf]
    USERFILE_FORMATS = [:fixture]
    
    ## Default configuration values, attributes and accessors defined here
    CONFIG_DEFAULTS = {
      :app_name                       => "Your New Project",    
      :protected_paths                => ["/"],
      :federation_metadata            => {"Example Federation"  => "/data/default_metadata/example_federation_metadata.xml".to_absolute_path,
                                          "UnCommon"            => "/data/default_metadata/uncommon_federation_metadata.xml".to_absolute_path,
                                          "Other Organisations" => "/data/default_metadata/local_metadata.xml".to_absolute_path},
      :home_path                      => "/",
      :exit_path                      => "/",
      :content_protection             => :active,
      :debug                          => true,
      :application                    => 'default',
      :entity_id                      => 'https://sp.example.ac.uk/shibboleth',
      :handler_path                   => "/Shibboleth.sso/",
      :status_path                    => "Status",
      :session_path                   => "Session",
      :login_path                     => "Login",
      :logout_path                    => "Logout",
      :df_path                        => "DiscoveryFeed",
      :ds_path                        => "DS",
      :sim_assertion_base             => "http://localhost/Shibboleth.sso/GetAssertion", 
      :sim_record_filter_module       => "Shibkit::Rack::Simulator::RecordFilter",
      :sim_remote_user                => %w"eppn persistent-id targeted-id",
      :sim_idp_session_expiry         => 300,
      :sim_sp_session_expiry          => 300,
      :sim_sp_session_idle            => 300,
      :sim_sp_use_metadata            => false,
      :sim_asset_base_path            => "/sim_assets/",
      :sim_idp_base_path              => "/sim_idp/",
      :sim_lib_base_path              => "/sim_lib/",
      :sim_dir_base_path              => "/sim_dir/",
      :sim_ggl_base_path              => "/sim_ggl/",
      :sim_wayf_base_path             => "/sim_wayf",
      :sim_idp_old_status_path        => "/idp/profile/Status", # TODO: Set per-simulated IDP, by metadata?
      :sim_idp_new_status_path        => "/idp/status",         # TODO: Set per-simulated IDP, by metadata?
      :sim_users_file                 => "/data/simulator_user_directory.yml".to_absolute_path,
      :sim_users_file_format          => :fixture,
      :sim_metadata_cache_file        => "/data/default_metadata_cache.yml".to_absolute_path,
      :sim_saml_authentication_method => 'urn:oasis:names:tc:SAML:1.0:am:unspecified', # Move to individual IDPs 
      :shim_attribute_map             => "/data/sp_attr_map.yml".to_absolute_path,
      :shim_user_id_name              => :user_id,
      :shim_sp_assertion_name         => :sp_session,
      :shim_org_settings_file         => "/data/organisation_settings.yml".to_absolute_path,
      :shim_org_access_file           => "/data/organisation_access_rules.yml".to_absolute_path,
      :debug_path                     => "/shibkit/debug",
      
      :sim_chooser_idp_sso            => false
    }
    
    ## Create accessors
    attr_accessor *CONFIG_DEFAULTS.keys
    
    ## New object. Takes block
    def initialize(&block) 

      ## Initialise with default variables
      CONFIG_DEFAULTS.each_pair {|k,v| self.instance_variable_set "@#{k}", v}
      
      ## Execute block if passed one      
      self.instance_eval(&block) if block
      
      ## Check nothing completely stupid is happening
      sane_configuration?
      
    end
    
    ## To set options as a block, since initialize isn't working # FIX
    def config(&block)
      
      self.instance_eval(&block) if block
      
      return self
      
    end
    
    ## Freeze the configuration
    def lock!
      
      self.freeze
      
    end
    
    ## Dump settings as text
    def to_s
      
      dump = String.new
      
      CONFIG_DEFAULTS.each_key do |k|
             
        v = self.send(k)
        fv = nil
        
        case v.class
        when Array
          fv = v.join(',')
        when Hash
          nfv = String.new
          fv.each_pair {|hk,hv| nfv << [hk,hv].join(',')  }
          fv = nfv
        else
          fv = v.to_s
        end
        
        dump << "#{k}: #{fv}\n" 
        
      end

      return dump

    end
    
    ## Dump settings as text
    def to_hash
      
      dump = Hash.new
      
      CONFIG_DEFAULTS.each_pair do |k,v|
        
        dump[k.to_sym] = v 
        
      end

      return dump

    end
      
    private
    
    ## Create absolute filepath from path relative to this file
    def absolute_path(relative_path)
      
      full_relative_path = ::File.join(::File.dirname(__FILE__), relative_path)
            
      return ::File.expand_path(full_relative_path)
      
    end
    
    ## Basic sanity check of settings (There are better ways of doing this...)
    def sane_configuration?
      
      ## Is the config sane? (Totally bad gets an exception instead of false)
      correct = true
      
      ##
      ## First check for exceptional situations
      ##
      
      ## Check that URI settings are proper URIs
      [:sim_sp_entity_id, :sim_saml_authentication_method].each do |m|

        begin
          URI.parse(self.send(m))
        rescue
          raise Shibkit::ConfigurationError, "#{m} is not a parsable URI"
        end
        
      end
      
      ## Check that symbol settings are symbols  
      [:shim_user_id_name, :shim_sp_assertion_name, :sim_chooser_type,
       :sim_users_file_format].each do |m|
         
         raise Shibkit::ConfigurationError, "#{m} is not a symbol! (Maybe change to :#{self.send(m)}?)" unless
           self.send(m).kind_of?(Symbol)
         
      end
       
      ## Check that limited options values are correct
      raise Shibkit::ConfigurationError, "Unknown chooser type!"    unless
        CHOOSER_FORMATS.include?(sim_chooser_type)
      raise Shibkit::ConfigurationError, "Unknown user file format!" unless
        USERFILE_FORMATS.include?(sim_users_file_format)
      
      ## Check file paths are valid and accessible - gather all our filenames
      gathered_filenames = Array.new
      [:sim_chooser_css, :sim_users_file, 
         :sim_chooser_css, :shim_attribute_map,
         :shim_org_settings_file, :shim_org_access_file].each do |m|
        
        filename = self.send(m)
        gathered_filenames << filename
        
      end
    
      ## Try each filename in turn
      gathered_filenames.flatten.each do |filename| 
      
        raise Shibkit::ConfigurationError, "Can't access file #{filename}" unless
          File.exists?(filename)
      
      end
      
      ## Check metadata by feeding it to MetaMeta
      #federation_metadata.each_pair do |name, source|
      #  MetaMeta::Source.new
      #
      #
      
       ## Check URL paths are valid
      [:home_path, :exit_path, :gateway_path, :sim_idp_base_path, :sim_wayf_base_path].each do |m|
        
        path     = self.send(m)
        test_url = "http://localhost" + path
        
        begin
          URI.parse(test_url)
        rescue
          raise Shibkit::ConfigurationError, "#{path} is not path (try something like '/mysite/page')"
        end
      
      end
      
      ##
      ##  Now check if config is production-ready and completely sensible
      ##
      
      ## ...
      
      return correct
      
    end
    
  end
  
end

module Shibkit
  
  ## Mixin to include
  module Configured

    ## Simple shortcut method to return Shibkit config object
    def config

      return ::Shibkit::Config.instance

    end

  end
  
end

## Open up Shibkit to insert method to access configuration
module Shibkit

  ## Class method to create, define and return configuration singleton
  def Shibkit.config(&block)

    if block
      return ::Shibkit::Config.instance.config(&block)   
    else
      return ::Shibkit::Config.instance
    end
    
  end

end
