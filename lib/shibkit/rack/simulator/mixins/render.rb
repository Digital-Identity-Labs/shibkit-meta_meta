module Shibkit
  module Rack
    class Simulator
      module Mixin
        module Render

          ## Load and prepare HAML views
          def views

            unless @views

              @views = Hash.new

              VIEWS.each do |view| 

                view_file_location = "#{::File.dirname(__FILE__)}/simulator/views/#{view.to_s}.haml"
                @views[view] = IO.read(view_file_location)

              end

            end

            return @views

          end

          ## Display a chooser page
          def render_page(view, locals={})

            ## HAML rendering options
            Haml::Template.options[:format] = :html5

            ## Render and return the page
            haml = Haml::Engine.new(views[view])
            return haml.render(Object.new, locals)

          end


        end
      end
    end
  end
end