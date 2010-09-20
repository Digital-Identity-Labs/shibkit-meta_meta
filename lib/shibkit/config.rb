require 'singleton'
require 'ftools'

module Shibkit
  class Config

    include Singleton
    
    CHOOSER_FORMATS  = [:simple, :ldap, :wayf]
    USERFILE_FORMATS = [:fixture]
    
    ## Default configuration values, attributes and accessors defined here
    CONFIG_DEFAULTS = {
      :path_auth_masks                => ["/"],
      :federation_metadata            => ["#{::File.dirname(__FILE__)}/data/example_federation_metadata.xml"],
      :home_path                      => "/",
      :exit_path                      => "/",
      :gateway_path                   => "/",
      :sim_debug                      => true,
      :sim_application                => 'default',
      :sim_chooser_idp_sso            => false,
      :sim_assertion_base             => "http://localhost/Shibboleth.sso/GetAssertion", 
      :sim_record_filter_module       => "Shibkit::Rack::Simulator::RecordFilter",
      :sim_sp_entity_id               => 'https://sp.example.ac.uk/shibboleth',
      :sim_remote_user                => %w"eppn persistent-id targeted-id",
      :sim_chooser_type               => :simple,
      :sim_chooser_css                => "#{::File.dirname(__FILE__)}/data/sp_sim.css",
      :sim_idp_session_expiry         => 300,
      :sim_sp_session_expiry          => 300,
      :sim_sp_session_idle            => 300,
      :sim_idp_base_path              => "/shibsim_idp/",
      :sim_wayf_base_path             => "/shibsim_wayf/",
      :sim_users_file                 => "#{::File.dirname(__FILE__)}/data/example_users.yml",
      :sim_users_file_format          => :fixture,
      :sim_orgs_file                  => "#{::File.dirname(__FILE__)}/data/example_orgs.yml",
      :sim_saml_authentication_method => 'urn:oasis:names:tc:SAML:1.0:am:unspecified',
      :shim_attribute_map             => "#{::File.dirname(__FILE__)}/data/sp_attr_map.yml",
      :shim_user_id_name              => :user_id,
      :shim_sp_assertion_name         => :sp_session,
      :shim_org_settings_file         => "#{::File.dirname(__FILE__)}/data/example_orgs_settings.yml",
      :shim_org_access_file           => "#{::File.dirname(__FILE__)}/data/example_orgs_access.yml" 
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
      [:sim_chooser_css, :sim_users_file, :federation_metadata,
         :sim_chooser_css, :sim_orgs_file, :sim_orgs_file, :shim_attribute_map,
         :shim_org_settings_file, :shim_org_access_file].each do |m|
        
        filename = self.send(m)
        gathered_filenames << filename
        
      end
    
      ## Try each filename in turn
      gathered_filenames.flatten.each do |filename| 
      
        raise Shibkit::ConfigurationError, "Can't access file #{filename}" unless
          File.exists?(filename)
      
      end
      
      
      
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
