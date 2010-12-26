##
##

require 'uuid'
require 'haml'
require 'yaml'
require 'time'
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

        ## Catching exceptions in the workflow/routing
        begin

          ## Route to actions according to requested URLs
          case request.path
          
          ## Return the global stylesheet
          when "/shibsim/stylesheet.css"
          
            return stylesheet_action(env, nil, {})
          
          ## Return image file
          when /\/shibsim\/images\//
            
            matches = request.path.match /\/images\/(\w+)(\.*.*)/
            specified = matches[1]
            
            return specified ?
              image_action(env, nil, {:image => specified}) :
              browser_404_action(env, nil, {})
              
          ## Does the path match the IDP regex?
          when idp_base_path_regex
            
            begin
              
              ## Extract the IDP id
              path = request.path.gsub(config.sim_idp_base_path, "")
              bits = %r|/*(\d+)(.*)|.match(path)
              
              raise "Bad IDP path '#{path}'" unless bits
              
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
            case idp_path
          
            ## IDP status information
            when idp_session.new_status_path
            
              return idp_new_status_action(env, sp_session)
              
            ## IDP status information
            when idp_session.old_status_path

              return idp_old_status_action(env, sp_session)

            ## IDP session information
            when idp_session.session_path
            
              return idp_session_action(env, sp_session) 
          
            ## Request is for the fake IDP's login function
            when '/', idp_session.login_path
          
              ## Specified a user? (GET or POST) then try logging in
              if request.params['user'] 
              
                return idp_login_action(env, sp_session)
                    
              ## Already logged in? With SSO log in again.
              elsif idp_session.sso? and idp_session.logged_in?
              
                return idp_sso_action(env, sp_session)
            
              ## Show the chooser page to present login options  
              else
            
                return idp_simple_chooser_action(env, sp_session)
              
              end
            
            ## IDP SLO request?     
            when idp_session.logout_path
              
              return idp_logout_action(env, sp_session)
          
            end
          
          ## WAYF request?
          when Model::WAYFSession.path
              
            return wayf_action(env, sp_session)  
            
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
      
      def idp_base_path_regex

        normalised_path = config.sim_idp_base_path.gsub(/\/$/, '')
        return Regexp.new(normalised_path)

      end
      
      # ...
  
    end

  end
end



