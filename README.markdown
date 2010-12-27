Shibkit
=======


Shibkit is a set of basic tools to help with Shibboleth SP web application development. It supports web applications based on Rack, Sinatra or Rails, although most features are focused on Rails. Rails 3.0 or higher is required.

Quick'n'Dirty setup notes that really need to be replaced by something coherent
-------------------------------------------------------------------------------

Load all the major Shibkit libraries by adding this to your application's Gemfile:

    gem "shibkit", :require => 'shibkit'

If you are working on Shibkit locally you can add 

   gem "shibkit", :require => 'shibkit', :path => "~/Projects/shibkit/workspace"

or to deploy directly from Github, you can use 

    gem "shibkit", :require => 'shibkit', :git => "git://github.com/binaryape/shibkit.git"

### Shibsim

Shibsim injects fake headers into your session, mimicking the output of an SP.
A real IDP and the WAYF/discovery process are replaced by a simple account chooser.

Shibsim is Rack middleware so it should work with both Rails and Sinattra. It's best
used for development, maybe testing. It is not a real authentication provider!

Enable Shibsim by adding the following to your Rails application.rb:

    config.middleware.use 'Shibkit::Rack::Simulator' if Rails.env == 'development'

Shibsim should work with its own built-in defaults. It isn't easily customisable yet, but this is due soon.

### Shibshim

Shibshim, named almost identically to its sister library to make your life slightly more confusing, aims to provide a consistent interface between your application and the Shibboleth SP software used to authenticate.

Shibshim reads headers passed by either a real SP installation or Shibsim, and wraps them up in a convenient user object.

Enabling Shibshim involves setting up both a Rack middleware and a (optional) Rails filter.

Add this line to your application.rb (or rackup.ru) after Shibsim:

    config.middleware.use 'Shibkit::Rack::Shim'

That will provide you with a user object in your session, with lots of nice accessor methods to provide information about the user, their IDP, organisation, etc.

### Rails Extras

A few Rails extensions are provided to handle sessions, authentication, etc.

To use them you need to extend your Application controller as follows:

    require  "shibkit/rails/core_controller_mixin"

    class ApplicationController < ActionController::Base

		   include Shibkit::Rails::CoreControllerMixin

       before_filter Shibkit::Rails::SessionFilter

       ...

You will need to provide a suitable User class. The one used by DIL at present is based on Mongoid. You'll need to write your own at this point, and I need to document what is needed... Eventually they'll be a generator for a default ActiveRecord one.

The session filter has lots of stages ordered as an authnz workflow. These are basic: the intention is that applications will subclass this filter and replace various stages with their own improved functionality. Dilkit contains filters like this.

### Mongoid Userstamps

Due to go into its own project at some point. This adds automatic owned_by, created_by, updated_by fields to Mongoid objects. Just put this into your model:

    include Mongoid::Userstamps

### Data Tools

Various utils for creating cargo-culted SP "data". 

    require 'shibkit/data_tools'

    DataTools.xsid

    ...

### MetaMeta

Library for reading a federation metadata XML file into in-memory objects. Doesn't completely work at present but considering the low LOC I'm suprised it works at all. Needs work.


### Credits

Thanks to

 - Tango Icon Theme 


Note on Patches/Pull Requests
=============================
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
=========
Copyright (c) 2010 Pete Birkinshaw. See LICENSE for details.
