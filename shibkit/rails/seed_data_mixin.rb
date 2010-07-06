require 'shibkit/data_tools'

module Shibkit
  module Rails
    module SeedDataMixin

      ## Loads YAML data into list of hashes, after parsing as a template with ERB
      def seed_data(klas)
  
        seed_file = ::Rails.root.join 'db', 'seeds', "#{klas.to_s.downcase.pluralize}.yml"
        seeds = YAML::load(ERB.new(IO.read(seed_file)).result)
        seeds.each {|seed| klas.create seed }

      end
      
    end
  end
end