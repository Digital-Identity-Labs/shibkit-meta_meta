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
      :status_handler                 => "Status",
      :session_handler                => "Session",
      :login_handler                  => "Login",
      :logout_handler                 => "Logout",
      :df_handler                     => "DiscoveryFeed",
      :ds_handler                     => "DS",
      :assertion_handler              => "GetAssertion", 
      :sim_remote_user                => %w"eppn persistent-id targeted-id",
      :sim_sp_session_expiry          => 300,
      :sim_sp_session_idle            => 300,
      :sim_sp_use_metadata            => false,
      :sim_asset_base_path            => "/sim_assets/",
      :sim_idp_base_path              => "/sim_idp/",
      :sim_lib_base_path              => "/sim_lib/",
      :sim_dir_base_path              => "/sim_dir/",
      :sim_ggl_base_path              => "/sim_ggl/",
      :sim_wayf_base_path             => "/sim_wayf",
      :sim_users_file                 => "/data/simulator_user_directory.yml".to_absolute_path,
      :sim_metadata_cache_file        => "/data/default_metadata_cache.yml".to_absolute_path, 
      :shim_attribute_map_file        => "/data/sp_attr_map.yml".to_absolute_path,
      :shim_user_id_name              => :user_id,
      :shim_sp_assertion_name         => :sp_session,
      :shim_org_settings_file         => "/data/organisation_settings.yml".to_absolute_path,
      :shim_org_access_file           => "/data/organisation_access_rules.yml".to_absolute_path,
      :debug_path                     => "/shibkit/debug",
      :demo_path                      => "/shibkit/demo"
    }
    
    PERMITTED_VALUES = {
      :content_protection             => [:active, :passive]
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
      
      
      ## Check each configuration option in turn, infering correct content from defaults
      CONFIG_DEFAULTS.each_pair do |setting, default_value|
        
        ## What is being used?
        current_value = self.send(m) 
        
        ## Use the default value to decide how to check the current value
        case default_value
        when /.yml$/
          validate_file(current_value)
          validate_yaml(current_value)
        when kind_of?(TrueClass), kind_of?(FalseClass)
          validate_boolean(current_value)
        when /uri/
          validate_uri(current_value)
        when /path/
          validate_path(current_value)
        when /symbol/
          validate_symbol(current_value)
        when /number/
          validate_seconds(current_value)
        end
        
        ## Use the setting name to check content
        case setting
        when /path/
          validate_path
        when /handler/
            
        
        ## Check for permitted values if they are defined
        if permitted_values = PERMITTED_VALUES[setting]
          
          validate_permitted_value(current_value, permitted_values)
          
        end
        
        
        
      end
      
      
      
      
      ######## OLD #######3
      
      ##
      ## First check for exceptional situations
      ##
      
      ## Check that URI settings are proper URIs
      [:entity_id, :sim_saml_authentication_method].each do |m|

        
        
      end
      
      ## Check that symbol settings are symbols  
      [:shim_user_id_name, :shim_sp_assertion_name,
       :sim_users_file_format].each do |m|
         
         raise Shibkit::ConfigurationError, "#{m} is not a symbol! (Maybe change to :#{self.send(m)}?)" unless
           self.send(m).kind_of?(Symbol)
         
      end

      ## Check file paths are valid and accessible - gather all our filenames
      gathered_filenames = Array.new
      [:sim_users_file, 
       :shim_attribute_map,
         :shim_org_settings_file, :shim_org_access_file].each do |m|
        
        filename = self.send(m)
        gathered_filenames << filename
        
      end
    
      ## Try each filename in turn
      gathered_filenames.flatten.each do |filename| 
      
      
      
      end
      
      ## Check metadata by feeding it to MetaMeta
      #federation_metadata.each_pair do |name, source|
      #  MetaMeta::Source.new
      #
      #
      
       ## Check URL paths are valid
      [:home_path, :exit_path, :sim_idp_base_path, :sim_wayf_base_path].each do |m|
        
        path     = self.send(m)
        test_url = "http://localhost" + path
        
      end
      
      ##
      ##  Now check if config is production-ready and completely sensible
      ##
      
      ## ...
      
      return correct
      
    end
    
    private
    
    ##
    def validate_uri(value)
      
      begin
        URI.parse(self.send(m))
      rescue
        raise Shibkit::ConfigurationError, "#{m} is not a parsable URI"
      end
      
    end
    
    ## 
    def validate_file(value)
      
        raise Shibkit::ConfigurationError, "Can't access file #{filename}" unless
          File.exists?(filename)
      
    end
    
    def validate_path(value)
      
      begin
        URI.parse(test_url)
      rescue
        raise Shibkit::ConfigurationError, "#{path} is not path (try something like '/mysite/page')"
      end
      
    end
    
    def validate_name(value)
      
      
    end
    
    def validate_boolean(value)
      
      
    end
    
    def validate_seconds(value)
      
      
    end
    
    def validate_symbol(value)
      
      
      
    end
    
    def validate_permitted_values(current_value, permitted_values)
    
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
