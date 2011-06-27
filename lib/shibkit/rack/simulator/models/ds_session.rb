module Shibkit
  module Rack
    class Simulator
      module Model
        class DSSession
          
          DEFAULT_RETURN_POLICY = "urn:oasis:names:tc:SAML:profiles:SSO:idpdiscovery-protocol:single"
          
          ## Easy access to Shibkit's configuration settings
          extend Shibkit::Configured
          
          attr_reader :ds_service
          attr_reader :ds_id
          
          attr_reader :origin
          
          attr_reader :term       
          attr_reader :shire      
          attr_reader :time       
          attr_reader :target     
          attr_reader :provider_id
           
          attr_reader :entity_id       
          attr_reader :return_to        
          attr_reader :policy          
          attr_reader :return_id_param 
          attr_reader :is_passive      
          
          attr_reader :request_type
          
          ## A new SPSession
          def initialize(env)
            
            ## Store reference to the Rack session: all object data will be stored
            ## in here - this class is really just an interface to part of session
            ## and aspects of configuration 
            @env = env
            
            ## Currently only one wayf is supported - this needs to be rewritten
            ## later to support multiple wayfs
            @ds_id = 1
            
            ## Make sure we have a data structure
            @env['rack.session']['shibkit-simulator']         ||= Hash.new
            @env['rack.session']['shibkit-simulator']['ds']   ||= Hash.new
            @env['rack.session']['shibkit-simulator']['ds'][@ds_id] ||= Hash.new
            @env['rack.session']['shibkit-simulator']['ds'][@ds_id][:ds_id] = @idp_id
            
            request = ::Rack::Request.new(env)
            
            ## Which IDP service are we represening  a session in?
            begin
              #@ds_service = Shibkit::Rack::Simulator::Model::DSService.find(@ds_id)
              @ds_service = Shibkit::Rack::Simulator::Model::DSService.new # Since identical... TODO: Variations
            rescue
              
              ## TODO need to raise exception here to deal with bad IDP ID.
              raise Rack::Simulator::ResourceNotFound, "Unable to find DS '#{@ds_id}'"
              
            end
            
            ## Remember previous visits
            ds_session_data[:previous_idps] ||= Array.new
            
            request     = ::Rack::Request.new(env)
            
            @origin = request.params['origin'].to_s
            
            ## Use these for now: hardcode into Simulator
            @term        = request.params['term'].to_s.downcase.strip[0..40]
            @shire       = request.params['shire'].to_s
            @time        = request.params['time'].to_i.to_s
            @target      = request.params['target'].to_s
            @provider_id = request.params['providerId'].to_s          
            
            ## Not working yet.
            @entity_id       = request.params['entityID'].to_s || 'entityID'
            @return_to       = request.params['return'].to_s
            @policy          = request.params['policy'].to_s || DEFAULT_RETURN_POLICY
            @return_id_param = request.params['returnIDParam'].to_s
            @is_passive      = request.params['isPassive'].to_s
            
            ## Quick hack to determine logic...
            @request_type    = :direct
            @request_type    = :wayf   if ! @shire.empty?
            @request_type    = :ds     if ! @return_to.empty? 
            @request_type    = :ui     if ! @term.empty?
             
          end
          
          ## Returns the authnRequest handler for the selected origin (or nil)
          def origin_sso_url
            
            return nil if origin.empty?
            
            idp = Shibkit::Rack::Simulator::Model::IDPService.find(origin)
            
            return idp.authn_url
                   
          end
          
          ## Session parameters to pass back into next request
          def feedback_data
            
            return case request_type
            when :wayf
              {
                "term"       => term,
                "shire"      => shire,
                "time"       => time,
                "target"     => target,
                "providerId" => provider_id
                }
            when :ds
              {  
                'entityID'      => entity_id,
                'return'        => return_to, 
                'policy'        => policy,
                'returnIDParam' => return_id_param,
                'isPassive'     => is_passive
              }
            else
              {}
            end
            
          end
          
          def wayf_request?
            
            return @request_type == :wayf
            
          end
          
          def ds_request?
            
            return @request_type == :ds
            
          end
          
          def ui_request?
            
            return @request_type == :ui
            
          end
          
          def direct_request?
            
            return @request_type == :direct
            
          end
          
          ## The optional WAYF path used in :wayf chooser mode  
          def self.path

            return config.sim_wayf_base_path

          end
          
          private
          
          ## Convenient accessor to this object's session data
          def ds_session_data
         
            return @env['rack.session']['shibkit-simulator']['ds'][@ds_id]
         
          end
                 
        end
      end
    end
  end
end




