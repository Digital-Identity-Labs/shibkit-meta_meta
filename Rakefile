require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "shibkit"
    gem.summary = %Q{Shibboleth data toolkit}
    gem.description = %Q{Rack and Rails libraries for using Shibboleth SP authentication and authorisation data}
    gem.email = "pete@binary-ape.org"
    gem.homepage = "http://github.com/binaryape/shibkit"
    gem.authors = ["Pete Birkinshaw"]

    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "cucumber", ">= 0"
    gem.add_development_dependency 'jscruggs-metric_fu', '1.1.5'
    gem.add_development_dependency "rspec-rails", "~> 2.0.0.beta.1"

    gem.add_dependency "json_pure", ">= 1.4.5"
    gem.add_dependency 'SystemTimer'
    gem.add_dependency 'haml', "~> 2.2.22"
    gem.add_dependency 'uuid'
    gem.add_dependency 'deep_merge'
    gem.add_dependency "nokogiri"

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

#require 'spec/rake/spectask'
#Spec::Rake::SpecTask.new(:spec) do |spec|
#  spec.libs << 'lib' << 'spec'
#  spec.spec_files = FileList['spec/**/*_spec.rb']
#end

#Spec::Rake::SpecTask.new(:rcov) do |spec|
#  spec.libs << 'lib' << 'spec'
#  spec.pattern = 'spec/**/*_spec.rb'
#  spec.rcov = true
#end

task :spec => :check_dependencies

#begin
#  require 'cucumber/rake/task'
#  Cucumber::Rake::Task.new(:features)
#
#  task :features => :check_dependencies
#rescue LoadError
#  task :features do
#    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
#  end
#end

begin
  require 'reek/adapters/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "shibkit #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
