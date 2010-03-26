class Rack::ShibShim

  def initialize(app)
    
    @app = app
    
  end

  def call(env)
    
    # return [200, {'Content-Type' => 'text/html'}, "Boo!"]
    
  end


end


# env['rack.session'][:user] || 'nil'

