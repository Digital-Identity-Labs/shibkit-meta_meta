# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
module Shibkit
  module Rails
    class ApplicationController < ActionController::Base
 
      helper :all # include all helpers, all the time
      protect_from_forgery # See ActionController::RequestForgeryProtection for details

      # Scrub sensitive parameters from your log
      # filter_parameter_logging :password
  
      include Shibkit::Rails::CoreControllerMixin
  
  
      ## prototype of 
      before_filter Shibkit::Rails::SessionFilter
  
    end
  end
end