# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{shibkit}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pete Birkinshaw"]
  s.date = %q{2010-03-14}
  s.description = %q{Rack and Rails libraries for using Shibboleth SP authentication and authorisation data}
  s.email = %q{pete@binary-ape.org}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "features/shibkit.feature",
     "features/step_definitions/shibkit_steps.rb",
     "features/support/env.rb",
     "lib/default_config/shibsim_config.yml",
     "lib/default_config/shibsim_filter.rb",
     "lib/default_data/federation_data.yml",
     "lib/default_data/idp_data.yml",
     "lib/default_data/user_data.yml",
     "lib/rack_views/fatal_error.haml",
     "lib/rack_views/user_chooser.haml",
     "lib/shib_shim.rb",
     "lib/shib_simulator.rb",
     "lib/shibkit.rb",
     "lib/shibsp_mapper.rb",
     "shibkit.gemspec",
     "spec/shibkit_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/binaryape/shibkit}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Shibboleth data toolkit}
  s.test_files = [
    "spec/shibkit_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<cucumber>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<cucumber>, [">= 0"])
  end
end

