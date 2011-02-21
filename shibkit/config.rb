require 'singleton'
require 'ftools'

class String
  
  ##
  ## Bodge to make paths easier to define dynamicly # TODO must be better way to do this...
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
      :sim_idp_behaviours_file        => "/data/simulator_idp_behaviours.yml".to_absolute_path,
      :sim_metadata_cache_file        => "/data/default_metadata_cache.yml".to_absolute_path, 
      :shim_attribute_map_file        => "/data/sp_attr_map.yml".to_absolute_path,
      :shim_user_id_name              => :user_id,
      :shim_sp_assertion_name         => :sp_session,
      :shim_org_settings_file         => "/data/organisation_settings.yml".to_absolute_path,
      :shim_org_access_file           => "/data/organisation_access_rules.yml".to_absolute_path,
      :debug_path                     => "/shibkit/debug/",
      :demo_path                      => "/shibkit/demo/"
    }
    
    PERMITTED_VALUES = {
      :content_protection             => [:active, :passive]
    }
    
    ## Create accessors
    attr_accessor *CONFIG_DEFAULTS.keys
    
    ##
    ## New object. Takes block
    def initialize(&block) 

      ## Initialise with default variables
      CONFIG_DEFAULTS.each_pair {|k,v| self.instance_variable_set "@#{k}", v}
      
      ## Execute block if passed one      
      self.instance_eval(&block) if block
      
      ## Check nothing completely stupid is happening
      sane_configuration?
      
    end
    
    ##
    ## To set options as a block, since initialize isn't working # FIX
    def config(&block)
      
      self.instance_eval(&block) if block
      
      return self
      
    end
    
    ##
    ## Freeze the configuration
    def lock!
      
      self.freeze
      
    end
    
    ##
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
    
    ##
    ## Dump settings as text
    def to_hash
      
      dump = Hash.new
      
      CONFIG_DEFAULTS.each_pair do |k,v|
        
        dump[k.to_sym] = v 
        
      end

      return dump

    end
      
    private
    
    ##
    ## Create absolute filepath from path relative to this file
    def absolute_path(relative_path)
      
      full_relative_path = ::File.join(::File.dirname(__FILE__), relative_path)
            
      return ::File.expand_path(full_relative_path)
      
    end
    
    ##
    ## Basic sanity check of settings (There are better ways of doing this...)
    def sane_configuration?
      
      ## Is the config sane? (Totally bad gets an exception instead of false)
      correct = true
           
      ## Check each configuration option in turn, infering correct content from defaults
      CONFIG_DEFAULTS.each_pair do |setting, default_value|
        
        ## What is being used?
        current_value = self.send(setting) 
        
        ## Foolishly use the default value to decide how to check the current value!
        case default_value
        when /.yml$/
          validate_file(current_value)
          validate_yaml(current_value)
        when kind_of?(TrueClass), kind_of?(FalseClass)
          validate_boolean(current_value)
        when /^(http:|urn:)/
          validate_uri(current_value)
        when /^\/.*\/$/
          validate_path(current_value)
        when kind_of?(Symbol)
          validate_symbol(current_value)
        when kind_of?(Fixnum)
          validate_seconds(current_value)
        when kind_of?(Array)
          validate_array(current_value)
        end
        
        ## Rashly use the setting name to check current value!
        case setting
        when /path$/
          validate_path(current_value)
        when /handler$/
          validate_handler(current_value)
        when "entity_id"
          validate_uri(current_value)
        when "federation_metadata"
          validate_federation_metadata(current_value)
        end
            
        ## Check for permitted values if they are defined
        if permitted_values = PERMITTED_VALUES[setting]
          
          validate_permitted_value(current_value, permitted_values)
          
        end
        
      end

      return correct
      
    end
    
    private
    
    ## #<-- TODO: all of these config validators are pretty weak. Need to be beefed up a bit.
    
    ##
    ## Make sure user-supplies a decent URI
    def validate_uri(value)
      
      begin
        URI.parse(self.send(value))
      rescue
        raise Shibkit::ConfigurationError, "#{value} is not a parsable URI"
      end
      
    end
    
    ##
    ## Checks that file exists
    def validate_file(value)
            
        raise Shibkit::ConfigurationError, "Can't access file #{value}" unless
          File.exists?(value)
      
    end
    
    ##
    ## Checks that file exists and is decent YAML
    def validate_yaml(value)
            
      begin
        YAML::load(File.open(value))
      rescue
        raise Shibkit::ConfigurationError, "Can't load file #{value} as YAML data"
      end
      
    end
    
    ##
    ## Check that path or path fragment for URL is acceptable
    def validate_path(value)
        
      test_url = "http://localhost" + value
           
      begin
        URI.parse(test_url)
      rescue
        raise Shibkit::ConfigurationError, "#{value} is not a suitable path (try something like '/mysite/page')"
      end
      
    end
    
    ##
    ## Names are just strings. Not much to check really.
    def validate_name(value)
    
      unless value.responds_to?(:to_s) and value.to_s.length > 0
    
        raise Shibkit::ConfigurationError, "#{value} is not a suitable name"
      
      end
      
    end
    
    ##
    ## True or false? Want literally True or False objects.
    def validate_boolean(value)
      
      unless value.kind_of?(TrueClass) or value.kind_of?(FalseClass)
        
        raise Shibkit::ConfigurationError, "#{value} should be true or false" 
        
      end
      
    end
    
    ##
    ## Just after a positive number really
    def validate_seconds(value)
      
      unless value.kind_of(Fixnum) and value > 0
        
        raise Shibkit::ConfigurationError, "#{value} should be a number of seconds greater than 0" 
        
      end
      
    end
    
    ##
    ## Just after a symbol.
    def validate_symbol(value)
      
      raise Shibkit::ConfigurationError, "#{value} is not a symbol!" unless
        value.kind_of?(Symbol)
      
    end
    
    ##
    ## Make sure value is in the list of permitted values
    def validate_permitted_value(value, permitted_values)
    
      raise Shibkit::ConfigurationError, "#{value} is not one of [#{permitted_values.flatten}]" unless
        permitted_values.include?(value)
    
    end
    
    ##
    ## Make bad metadata fail early?
    def validate_federation_metadata(current_value)
    
      # ...
    
    end
    
  end
  
end

module Shibkit
  
  ## Mixin to include
  module Configured

    ##
    ## Simple shortcut method to return Shibkit config object
    def config

      return ::Shibkit::Config.instance

    end

  end
  
end

## Open up Shibkit to insert method to access configuration
module Shibkit

  ##
  ## Class method to create, define and return configuration singleton
  def Shibkit.config(&block)

    if block
      return ::Shibkit::Config.instance.config(&block)   
    else
      return ::Shibkit::Config.instance
    end
    
  end

end
