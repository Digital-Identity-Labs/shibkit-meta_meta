module Shibkit
  module Rails
    module CoreControllerMixin
      
      private
      
      ## Return the model for the currently logged in user
      def current_user
  
        @current_user ||= User.find(session[:user_id] || 0)
        return @current_user
  
      end

      ## 
      def sp_session
  
        return session[:sp_session]
  
      end

      def authenticated?
  
        return true if current_user && current_user.id.to_s > 0
  
      end
        
      def wobble?
  
        return true if current_user && current_user.id.to_s > 0
  
      end
        
   end
 end
end