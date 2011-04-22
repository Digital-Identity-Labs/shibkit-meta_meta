module Shibkit
  module Rack
    class Simulator
      module Mixin
        module SPActions
               
          ####################################################################
          ## SP Actions
          ##
          
          ## Controller for showing SP status
          def sp_status_action(env, sp_session, options={}) 

            code = options[:code].to_i || 200
            
            locals = get_locals(
              :layout     => :plain_layout,
              :sp_session => sp_session,
              :sp_service => sp_session.sp_service,
              :config     => config,
              :page_title => ""
              )  
                  
              page_body = render_page(:sp_status, locals)

              return code, Shibkit::Rack::HEADERS, [page_body.to_s]
                 
          end 
          
          ## Controller for showing SP Metadata
          def sp_metadata_action(env, sp_session, options={}) 

            code = options[:code].to_i || 200
            
            locals = get_locals(
              :layout     => :plain_layout,
              :sp_session => sp_session,
              :sp_service => sp_session.sp_service,
              :config     => config,
              :page_title => ""
              )  
                  
              page_body = render_page(:sp_metadata, locals)

              return code, Shibkit::Rack::HEADERS, [page_body.to_s]
                 
          end 
          
                   
          ## Controller for showing SP session information
          def sp_session_action(env, sp_session, options={}) 

            code = options[:code].to_i || 200
            
            ## No session to show? Fail realistically and politely
            unless sp_session.logged_in?
              
              locals = get_locals(
                :layout     => :minimal_layout,
                :ugly       => true,
                :page_title => "Session Summary"
                )

              page_body = render_page(:sp_session_not, locals)

              return code, Shibkit::Rack::HEADERS, [page_body.to_s]
                      
            end
            
            ## Assemble various stats for the page
            stats = {
              :ip_address                   => env['REMOTE_ADDR'], # TODO store in session and read...
              :idp_entity_uri               => sp_session.identity_provider,
              :sso_protocol                 => sp_session.idp_assertion.protocol,
              :authentication_time          => sp_session.login_time.utc.xmlschema,
              :authentication_context_class => sp_session.idp_assertion.auth_method,
              :authentication_context_decl  => "(none)",
              :minutes_remaining            => sp_session.minutes_until_expiry
            }  
            
            attribute_stats = Hash.new
            sp_session.attributes.each_pair { |k,v| attribute_stats[k] = [v].flatten.count }
            
            locals = get_locals(
              :layout     => :minimal_layout,
              :ugly       => true,
              :stats      => stats,
              :attribute_stats => attribute_stats,
              :page_title => "Session Summary"
              )
            
            page_body = render_page(:sp_session, locals)
 
            return code, Shibkit::Rack::HEADERS, [page_body.to_s]

          end
          
          ## Receive authentication assertion from IDP
          def sp_sso_action(env, sp_session, options={})
            
            request = ::Rack::Request.new(env)
            
            target           = request.params['TARGET'].to_s
            encoded_response = request.params['YAMLResponse'].to_s
            
            log_debug "Encoded YAML assertion received"
            raise "Y/SAML Error" unless encoded_response # TODO: Better SP error handling

            sp_session.login!(encoded_response)
            
            if sp_session.logged_in?
              
              return redirect_to sp_session.destination 
              
            else
              
              raise "Failed to login" # TODO Better error handling here too
              
            end
            
          end
          
          ## Controller for handling protected pages with active session
          def sp_active_action(env, sp_session, options={})
            
            sp_session.access!
            
            return @app.call(env)
            
          end
 
          ## Controller for handling protected pages with passive (lazy) session
          def sp_passive_action(env, sp_session, options={})
            
            sp_session.access!
            
            return @app.call(env)
            
          end
          
          ## Controller for
          def sp_login_action(env, sp_session, options={})
            
            ## Assemble params for WAYF AuthnRequest, old style # TODO: DS protocol
            details = Hash.new
            details[:time]        = Time.new.to_i
            details[:shire]       = sp_session.sp_service.login_path
            details[:provider_id] = sp_session.sp_service.uri
            details[:target]      = sp_session.target
            
            params = ::Rack::Utils.build_query(details) 

            return redirect_to(config.sim_wayf_base_path + "/?" + params)
            
          end
          
        end
      end
    end
  end
end
