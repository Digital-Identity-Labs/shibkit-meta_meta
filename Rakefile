# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "shibkit-meta_meta"
  gem.homepage = "http://github.com/binaryape/shibkit-meta_meta"
  gem.license = "Apache 2.0"
  gem.summary = %Q{Downloads and parses Shibboleth (SAML2) metadata.}
  gem.description = %Q{Utilities for friendly handling of Shibboleth/SAML2 metadata. Easily download and parse metadata XML into Ruby objects.}
  gem.email = "gems@digitalidentitylabs.com"
  gem.authors = ["Pete Birkinshaw"]
  gem.files.exclude 'lib/scratch_test.rb'
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/**/*_spec.rb']
end

task :default => :spec

