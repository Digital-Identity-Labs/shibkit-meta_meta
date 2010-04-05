class Rack::ShibShim

  require 'shib_user'

  def initialize(app)
    
    @app = app
    
  end

  def call(env)
    
    shib_user = ShibUser::Assertion.new(env,env)
      
    env["rack.session"][:shib_user] = shib_user  
    
    puts "passing through"
    
    return @app.call(env)
    
  end

  private
  
  ## Extract init data for user object 
  def process_sp_session
    
    
    
  end
  
  ## Extract attribute data from environment
  def process_sp_core_attributes
    
    
    
  end
  
  ## Extra attribute data from environment
  def process_sp_ext_attributes
    
    
    
    
  end
  
end
