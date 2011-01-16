module Shibkit
  module Rack
    class Simulator
      module Mixin
        module Actions
          
          
          ## Redirect browser to a new Simulator URL
          def redirect_to(path)
            
            url = path
            
            return 302, {'Location'=> url }, []
            
          end
          
          ## Return the global stylesheet
          def stylesheet_action(env, nil_session, options={})
              
            code = 200
            page_body = asset("stylesheet.css")

            return code, {"Content-Type" => "text/css; charset=utf-8"}, [page_body.to_s]
        
          end
          
          ## Return the appropriate image for something from a path ending in /image/something
          def javascript_action(env, nil_session, options={})
            
            ## TODO: Needs to be a bit fancier and less SVG-hardcoded (made into another lib?)
      
            specified = options[:specified] || "alert"
            
            page_body = asset(specified + ".js")
            
            code = 200
            
            return code, {"Content-Type" => "text/javascript"}, [page_body.to_s]
        
          end
          
          ## Return the appropriate image for something from a path ending in /image/something
          def image_action(env, nil_session, options={})
          
            specified = options[:specified] || "placeholder"
            
            extension    = ".svg"
            content_type = "image/svg+xml"
            page_body    = ""
            
            formats = [
              [".svg", "image/svg+xml"],
              [".png", "image/png"]
            ]
            
            ## Try each format in order (an ordered hash in 1.8 would have been nice)
            formats.each do |ext_and_mime|
              
              ext, mime = ext_and_mime
              
              page_body    = asset(specified + ext)
              content_type = mime
              
              break unless page_body.to_s.empty? 
              
            end
            
            return browser_404_action(env, nil, {}) unless page_body
            
            return 200, {"Content-Type" => content_type}, [page_body.to_s]
        
          end
          
          ## Displayed if no IDP ID is provided, or if it cannot be found
          def browser_404_action(env, sim_session, options={})
          
            message = options[:message]
            
            code = 404
            
            locals = get_locals(
              :layout => :browser_layout,
              :idps => [],
              :code => code,
              :requested => env['REQUEST_URI'],
              :page_title => "Simulated Server Not Found"
              ) 
            
            page_body = render_page(:browser_404, locals)

            return code, CONTENT_TYPE, [page_body.to_s]
          
          end
          
          ## Displayed if no IDP ID is provided, or if it cannot be found
          def idp_404_action(env, sim_session, options={})
          
            message = options[:message]
            code = options[:code].to_i || 404
            
            locals = get_locals(
              :idps => [],
              :page_title => "IDP Cannot Be Found"
              ) 
            
            page_body = render_page(:idp_404, locals)

            return 404, CONTENT_TYPE, [page_body.to_s]
          
          end
          
          ## Controller for new-style IDP status
          def idp_new_status_action(env, idp_session, options={})
                   
            message = options[:message]
            code = options[:code].to_i || 404
            
            locals = get_locals(
              :idps => [],
              :layout => :plain_layout,
              :page_title => "IDP Status",
              :start_time => START_TIME.utc.xmlschema,
              :time_now   => Time.new.utc.xmlschema,
              :entity_id  => idp_session.idp_service.uri
              ) 
            
            page_body = render_page(:idp_new_system_status, locals)

            return 200, {"Content-Type" => "text/plain; charset=utf-8"}, [page_body.to_s]
            
          end  
               
          ## Controller for old "OK" status page
          def idp_old_status_action(env, idp_session, options={})
                   
            code = options[:code].to_i || 200
            
            render_locals = {:layout => :plain_layout}
            
            ## Very basic check to see if we have an IDP...
            if idp_session.idp_service
              
              page_body = render_page(:idp_old_system_status, locals)
 
              return code, {"Content-Type" => "text/plain; charset=utf-8"}, [page_body.to_s]
   
            else
              
              raise Rack::Simulator::ResourceNotHappy
              
            end
            
          end
          
          ## Controller to display login page
          def idp_form_action(env, idp_session, options={})
          
            message = options[:message] || idp_session.get_message
            
            code = 200
            
            locals = get_locals(
              :layout     => :layout,
              :idp        => idp_session.idp_service,
              :sp_home    => config.home_path,
              :sp_name    => config.app_name,
              :directory  => idp_session.idp_service.directory,
              :page_title => "#{idp_session.idp_service.display_name} IDP",
              :message    => message
              ) 
            
            page_body = render_page(:idp_form, locals)

            return code, CONTENT_TYPE, [page_body.to_s]
           
          end
                   
          ## Controller for logging in to IDP
          def idp_login_action(env, idp_session, options={})
          
            message = options[:message]
            
            code = 200
            
            ## Are we passed suitable info?
            req = ::Rack::Request.new(env)
            username = req.params['username']
            password = req.params['password']
            dest_raw = req.params['destination']

            ## Are we passed suitable info?
            if username.empty? or password.empty?
              
              idp_session.set_message("Please enter your username and password")
              
              return redirect_to idp_session.login_path
            
            end
            
            ## Authenticate using the IDP's directory service
            user_id = idp_session.idp_service.directory.authenticate(username, password)
              
            ## Check that actually worked...
            unless user_id
              
              ## Explain to user what has happened
              idp_session.set_message("Failed to login. Password or username is incorrect.")
              
              ## User has not logged in. Probably doesn't exist!
              return redirect_to idp_session.login_path
              
            end
                         
            ## Authenticate the user?
            if idp_session.login!(username)
            
               locals = get_locals(
                 :layout => :layout,
                 :page_title => "Forwarding you...",
                 :destination => URI.unescape(dest_raw)
                 ) 

               page_body = render_page(:idp_redirect, locals)

               return code, CONTENT_TYPE, [page_body.to_s]
            
            else
              
              ## This is odd TODO Raise an error here
              raise "EH? User #{user_id} has failed to login to IDP, but is in directory"
              return redirect_to idp_session.login_path
              
            end
            
          end
          
          ## Controller for
          def idp_sso_action(env, options={})
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]
            
          end
          
          ## Controller for
          def idp_logout_action(env, options={})
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]
            
          end
          
          ## Controller for directory Search/List 
          def directory_list_action(env, directory, options={})
            
            #message = options[:message] || idp_session.get_message

             code = 200

             locals = get_locals(
               :layout     => :layout,
               :directory  => directory,
               :page_title => directory.display_name,
               :message    => "message"
               ) 

             page_body = render_page(:directory_list, locals)

             return code, CONTENT_TYPE, [page_body.to_s]
                
          end

          ## Controller for directory entry 
          def directory_item_action(env, directory, options={})
            
            #message = options[:message] || idp_session.get_message

             code = 200

             locals = get_locals(
               :layout     => :layout,
               :directory  => directory,
               :user       => options[:account],
               :page_title => directory.display_name,
               :message    => "message"
               ) 

             page_body = render_page(:directory_item, locals)

             return code, CONTENT_TYPE, [page_body.to_s]
                
          end
          
          ## Controller for simple Library page (done differently. TODO: Change?)
          def library_action(env)
            
            begin
              
              request = ::Rack::Request.new(env)
              
              ## Extract the IDs
              path = request.path.gsub(config.sim_lib_base_path, "")
              idp_id = path.split('/')[0] || nil

              ## Clean things up a bit.
              idp_id  = idp_id.to_i.to_s
              
              ## Get the IDP session object
              idp = Model::IDPService.find(idp_id) 

              ## Missing Dir id? Show a 404 sort of thing
              unless idp_id and idp

                raise Rack::Simulator::ResourceNotFound, "Unable to find Library with suitable Shibboleth IDP (#{idp_id})"

              end

            rescue Rack::Simulator::ResourceNotFound => oops

                return browser_404_action(env, nil, {})

            end
          
            code = 200

            locals = get_locals(
              :layout     => :layout,
              :idp        => idp,
              :page_title => "Online Resources at #{idp.display_name} Library"
              ) 

            page_body = render_page(:library, locals)

            return code, CONTENT_TYPE, [page_body.to_s]
                      
          end
          
          ## Controller for mockup of search engine (OK, WHY? For direct links to home and subpages) 
          def search_action(env, sp_session, options={})
                    
            code = 200

            locals = get_locals(
              :layout     => :layout,
              :javascript => :ggl,
              :sp         => sp_session, # TODO: should this be the service instead?
              :page_title => "Shibkitoogle"
              ) 

            page_body = render_page(:ggl, locals)

            return code, CONTENT_TYPE, [page_body.to_s]
                      
          end
          
          ## Controller for
          def wayf_action(env, wayf_session, options={})
            
            request = ::Rack::Request.new(env)
            term = request.params['term'].to_s.downcase.strip[0..40]
            idps = Shibkit::Rack::Simulator::Model::IDPService.all
            
            code = 200
              
            ## We've got a term request so respond with JSON
            unless term.empty?  
              
              results = Array.new
              
              idps.each do |idp|
              
                if idp.display_name.downcase =~ /#{term}/  
              
                  result = Hash.new
                  result['id']    = idp.id
                  result['label'] = idp.display_name
                  result['value'] = idp.display_name
                 
                  results << result
                  
                end
              
              end
              
              page_body = results.to_json
              
              puts page_body
              
              return code,
                { "Content-Type" => "application/json" },
                page_body
              
            end  
                                   
            locals = get_locals(
              :layout     => :layout,
              :javascript => :wayf,
              :wayf       => wayf_session, # TODO: should this be the service instead?
              :idps       => idps.sort! { |a,b| a.display_name.downcase <=> b.display_name.downcase },
              :page_title => "Select Your Home Organisation"
            )
            
            page_body = render_page(:wayf_smart, locals)
              
            return code, CONTENT_TYPE, [page_body.to_s]
                
          end
          
          ## Controller for showing SP session status
          def sp_session_action(env, options={}) 

            code = options[:code].to_i || 200
  
            "A valid session was not found."
  
            ## Assemble various stats for the page
            stats = {
              :ip_address                   => env['REMOTE_ADDR'], # TODO store in session and read...
              :idp_entity_uri               => "TODO",
              :sso_protocol                 => "TODO",
              :authentication_time          => sim_sp_session(env)[:logintime],
              :authentication_context_class => "TODO",
              :authentication_context_decl  => "TODO",
              :minutes_remaining            => "TODO",
              :attributes_stats             => {
                'todo' => 'todo'
              }
            }  

            page_body = render_page(:user_chooser, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]

          end
          
          ## Controller for
          def sp_protected_page_action(env, options={})
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]
            
          end
          
          ## Controller for
          def sp_login_action(env, options={})
            
            message = options[:message]
            code = options[:code].to_i || 200
            
            render_locals = {}
            
            page_body = render_page(:x, render_locals)
 
            return code, CONTENT_TYPE, [page_body.to_s]
            
          end

          ## Error page for unrecoverable situations
          def fatal_error_action(env, oops)

            log_debug("****  Fatal error: #{oops}")

            unless ENV['RACK_ENV'] == :production or ENV['RAILS_ENV'] == :production

              puts "\nBacktrace is:\n#{oops.backtrace.to_yaml}\n"

            end

            render_locals = { :message => oops.to_s }
            page_body = render_page(:fatal_error, render_locals)

            return 500, CONTENT_TYPE, [page_body.to_s]

          end
          
          def get_locals(*specified_locals)
            
            return {
              :page_title   => "Shibkit",
              :code         => 200,
              :assets_base  => config.sim_asset_base_path,
              :content_type => CONTENT_TYPE
            }.merge *specified_locals
            
          end

        end
      end
    end
  end
end
