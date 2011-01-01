##
##

require 'uuid'
require 'haml'
require 'yaml'
require 'time'
require 'uri'
require 'rack/logger'

## Require various mixins too
require 'shibkit/rack/simulator/mixins/render'
require 'shibkit/rack/simulator/mixins/actions'
require 'shibkit/rack/simulator/mixins/injection'
require 'shibkit/rack/simulator/mixins/logging'

## Default record filter mixin code
require 'shibkit/rack/simulator/record_filter'
require 'shibkit/rack/simulator/exceptions'

## Models to manage sessions and authnz behaviour
require 'shibkit/rack/simulator/models/account'
require 'shibkit/rack/simulator/models/directory'
require 'shibkit/rack/simulator/models/federation'
require 'shibkit/rack/simulator/models/idp_session'
require 'shibkit/rack/simulator/models/idp_service'
require 'shibkit/rack/simulator/models/sp_service'
require 'shibkit/rack/simulator/models/sp_session'
require 'shibkit/rack/simulator/models/wayf_service'
require 'shibkit/rack/simulator/models/wayf_session'

module Shibkit
  
  module Rack
  
    class Simulator
      
      ## Methods have been split up into mixins to make things more manageable
      include Shibkit::Rack::Simulator::Mixin::Injection
      include Shibkit::Rack::Simulator::Mixin::Render
      include Shibkit::Rack::Simulator::Mixin::Actions
      include Shibkit::Rack::Simulator::Mixin::Logging
      
      ## Easy access to Shibkit's configuration settings
      include Shibkit::Configured
    
      ## Middleware application components and behaviour
      CONTENT_TYPE   = { "Content-Type" => "text/html; charset=utf-8" }
      START_TIME     = Time.new
    
      def initialize(app)
      
        ## Rack app
        @app = app
        
        ## Load federations, and everything they contain
        Shibkit::Rack::Simulator::Model::Federation.load_records
        
      end
      
      ## Selecting an action and returning to the Rack stack 
      def call(env)
      
        ## Peek at user input, they might be talking to us
        request = ::Rack::Request.new(env)
        
        ## Model representing SP state (knows about IDPs, WAYF, etc)
        sp_session = Model::SPSession.new(env)

        ## Catching top-level exceptional exceptions in the workflow/routing
        ## (404s etc will be handled inside this, hopefully)
        begin

          ## Route to actions according to requested URLs
          case request.path
          
          ####################################################################
          ## Asset Routing
          ##
          
          ## Return the global stylesheet
          when "#{config.sim_asset_base_path}/stylesheet.css"
          
            return stylesheet_action(env, nil, {})

          ## Return a Javascript file
          when /#{Regexp.escape(config.sim_asset_base_path)}\/scripts\//

            matches = request.path.match /\/scripts\/(\w+)(\.*.*)/
            specified = matches[1]

            return specified ?
              javascript_action(env, nil, {:specified => specified}) :
              browser_404_action(env, nil, {})

          ## Return image file
          when /#{Regexp.escape(config.sim_asset_base_path)}\/images\//
            
            matches = request.path.match /\/images\/(\w+)(\.*.*)/
            specified = matches[1]
            
            return specified ?
              image_action(env, nil, {:specified => specified}) :                         
              browser_404_action(env, nil, {})
          
          ####################################################################
          ## IDP Routing
          ##
             
          ## Does the path match the Directory regex?
          when base_path_regex(config.sim_idp_base_path)
            
            begin
              
              ## Extract the IDP id
              path = request.path.gsub(config.sim_idp_base_path, "")
              bits = %r|/*(\d+)(.*)|.match(path)
              
              raise "Bad Directory path '#{path}'" unless bits
              
              idp_id  =  bits[1]
              idp_path = bits[2] || '/'
              
              ## Get the IDP session object
              idp_session = Model::IDPSession.new(env, idp_id) 

              ## Missing IDP id? Show a 404 sort of thing
              unless idp_id && idp_session and idp_session.idp_service
                
                raise Rack::Simulator::ResourceNotFound, "Unable to find IDP '#{idp_id}'"

              end
              
            rescue Rack::Simulator::ResourceNotFound => oops
      
              return browser_404_action(env, idp_session, {})
            
            end
            
            ## Check again, focusing on the IDP's subpath
            case request.path
                  
            ## IDP status information
            when idp_session.new_status_path
              
              return idp_new_status_action(env, idp_session)
              
            ## IDP status information
            when idp_session.old_status_path

              return idp_old_status_action(env, idp_session)

            ## Request is for the fake IDP's login function
            when idp_session.service_base_path,
                 idp_session.service_root_path,
                 idp_session.login_path
              
              ## Posting form data?
              if request.request_method.downcase == "post" 
                
                return idp_login_action(env, idp_session)
                    
              ## Already logged in? With SSO? Log in again.
              elsif idp_session.sso? and idp_session.logged_in?
                
                return idp_sso_action(env, idp_session)
            
              ## Show the login page  
              else
                
                return idp_form_action(env, idp_session)
              
              end
            
            ## IDP SLO request?     
            when idp_session.logout_path
              
              return idp_logout_action(env, idp_session)
          
            end

            
          ####################################################################
          ## Directory Routing
          ##
                    
          ## Does the path match the Directory base regex?
          when base_path_regex(config.sim_dir_base_path)

            begin
              
              ## Extract the IDs
              path = request.path.gsub(config.sim_dir_base_path, "")
              dir_id, blah, user_id = path.split('/')
              
              ## Clean things up a bit.
              dir_id  = dir_id.to_i.to_s
              user_id = user_id.to_i.to_s

              ## Get the IDP session object
              directory = Model::Directory.find(dir_id) 

              ## Missing Dir id? Show a 404 sort of thing
              unless dir_id and directory

                raise Rack::Simulator::ResourceNotFound, "Unable to find Directory '#{dir_id}'"

              end
              
              ## Should we show user details?
              if user_id and user_id.to_i > 0
              
                return directory_item_action(env, directory, {:account => user_id})
              
              else
                
                ## Just show the index instead
                return directory_list_action(env, directory)
                
              end
              
            rescue Rack::Simulator::ResourceNotFound => oops

              return browser_404_action(env, idp_session, {})

            end
          
          ####################################################################
          ## Library Routing (done slightly differenly as an experiment TODO: hmm.)
          ##
          when base_path_regex(config.sim_lib_base_path)
            
            return library_action(env) 
          
          ####################################################################
          ## Search Routing 
          ##
          when base_path_regex(config.sim_ggl_base_path)

            return search_action(env, sp_session, {})
          
          ####################################################################
          ## WAYF Routing
          ##
    
          ## WAYF request?
          when Model::WAYFSession.path
              
            return wayf_action(env, wayf_session)  
     
          ####################################################################
          ## SP Routing
          ##
     
          ## SP session status page?
          when sp_session.session_path
              
            return sp_session_status_action(env, sp_session)
          
          ## SP protected page?    
          when sp_session.masked_paths[0]
            
            ## Valid session in SP
            if sp_session.logged_in?
              
              return sp_protected_page_action(env, sp_session)
              
            else
              
              return sp_login_action(env, sp_session)
              
            end
            
          else
            
            ## Do nothing, pass on up to the application
            return @app.call(env)
            
        end

        ## Catch any errors generated by this middleware class. Do not catch other Middleware errors.
        rescue Rack::Simulator::RuntimeError => oops
        
          ## Render a halt page
          return fatal_error_action(env, oops)
    
        end

      end
      
      private
      
      ## Reformat the base path for IDP URLs to capture info in URL
      def base_path_regex(base_path)

        normalised_path = base_path.gsub(/\/$/, '')
        return Regexp.new(normalised_path)

      end
  
    end

  end
end



