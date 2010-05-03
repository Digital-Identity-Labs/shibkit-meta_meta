

## Returnt the model for the currently logged in user
def current_user
  
  return User.get(session[:user_id])
  
end
