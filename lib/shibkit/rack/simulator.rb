##
##

require 'uuid'
require 'haml'
require 'yaml'
require 'time'
require 'uri'
require 'rack/logger'
require 'json'


## 
require 'shibkit/rack/base'
require 'shibkit/rack/assets'

module Shibkit
  
  module Rack
  
    class Simulator < Shibkit::Rack::Base
      
       
      
      ## Require various mixins too
      require 'shibkit/rack/simulator/mixins/browser_actions'
      require 'shibkit/rack/simulator/mixins/dir_actions'
      require 'shibkit/rack/simulator/mixins/ds_actions'
      require 'shibkit/rack/simulator/mixins/idp_actions'
      require 'shibkit/rack/simulator/mixins/lib_actions'
      require 'shibkit/rack/simulator/mixins/search_actions'
      require 'shibkit/rack/simulator/mixins/sp_actions'
      require 'shibkit/rack/simulator/mixins/injection'

      ## Models to manage sessions and authnz behaviour
      require 'shibkit/rack/simulator/models/all'

      
      ## Methods have been split up into mixins to make things more manageable
      include Shibkit::Rack::Simulator::Mixin::Injection
      include Shibkit::Rack::Simulator::Mixin::BrowserActions
      include Shibkit::Rack::Simulator::Mixin::DirActions
      include Shibkit::Rack::Simulator::Mixin::DSActions
      include Shibkit::Rack::Simulator::Mixin::IDPActions
      include Shibkit::Rack::Simulator::Mixin::LibActions
      include Shibkit::Rack::Simulator::Mixin::SPActions
    
      def initialize(app)
        
        ## Rack app
        @app = app
        
        @token_attribute = "ahahaha"
        
        #unless class_exists? "Shibkit::Rack::Assets"
        # 
        #@app = Shibkit::Rack::Assets.new(@app)# unless contains_middleware?('Shibkit::Rack::Assets') 
        
        ##
        #@app.use 'Shibkit::Rack::Assets'

        ## Load federations, and everything they contain
        Shibkit::Rack::Simulator::Model::Federation.load_records
           
      end
      
      ## Selecting an action and returning to the Rack stack 
      def call(env)
      
        ## Peek at user input, they might be talking to us
        request = ::Rack::Request.new(env)
        
        ## Models representing SP state (knows about IDPs, WAYF, etc)
        sp_session = Model::SPSession.new(env)
        sp_service = sp_session.sp_service
        
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
            case request.url.split('?')[0].gsub(/\/$/, '')
            
           
            
            ## IDP status information
            when idp_session.idp_service.new_status_url
              
              return idp_new_status_action(env, idp_session)
              
            ## IDP status information
            when idp_session.idp_service.old_status_url

              return idp_old_status_action(env, idp_session)
              
            when idp_session.idp_service.authn_url
                      
              return idp_authn_action(env, idp_session)
              
            ## Request is for the fake IDP's login function
            when idp_session.idp_service.login_url
          
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
            when idp_session.idp_service.logout_path
             
              return idp_logout_action(env, idp_session)
          

            ## IDP Authn request?     
            when idp_session.idp_service.authn_path
                    
              return idp_authn_action(env, idp_session)
          
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
          ## DS/WAYF Routing
          ##
    
          ## WAYF request?
          when base_path_regex(Model::DSSession.path)
              
            return ds_action(env, nil)  
     
          ####################################################################
          ## SP Routing
          ##
          
          ## SP session page?
          when sp_service.session_path
              
            return sp_session_action(env, sp_session)
          
          ## SP status page?
          when sp_service.status_path
            
            return sp_status_action(env, sp_session)
          
          ## SP Login session initiator action
          when sp_service.login_path
          
            return sp_login_action(env, sp_session)
          
          ## SP protected page?    
          when *sp_service.protected_path_patterns
            
            puts sp_session.required?
            puts sp_session.logged_in?
            
            ## Valid session in SP
            if sp_session.required? && sp_session.logged_in?
              
              return sp_active_action(env, sp_session)
              
            elsif sp_session.required?
              
              return sp_login_action(env, sp_session)
             
            end
          
          else
            
            ## Insert data if it exists, pass control to application (or next Rack middleware)
            return sp_passive_action(env, sp_session)
            #return @app.call(env)
            
        end

        ## Catch any errors generated by this middleware class. Do not catch other Middleware errors.
        rescue ::Shibkit::Rack::Simulator::RuntimeError, ::RuntimeError => oops
        
          ## Render a halt page
          return fatal_error_action(env, oops)
    
        end

      end
      
      private
      
      def class_exists?(class_name)
        
        begin
        
          klass = Module.const_get(class_name)
          
          return klass.is_a?(Class)
        
        rescue NameError
        
          return false
        
        end
        
      end
  
    end

  end
end



