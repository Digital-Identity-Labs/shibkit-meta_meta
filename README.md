Shibkit::MetaMeta - Lazy SAML Metadata Access
==============================================

## DESCRIPTION

SAML2 Metadata is widely used in education to build federations - groups of trusted IDPs (login servers) and SPs (websites using the IDPs for authentication). 

MetaMeta is the first part of Shibkit to be released.

### Why use Shibkit::MetaMeta?

There are few reasons to use MetaMeta if you are running an IDP or a simple authenticated website. However, if you are building a more advanced web application that needs to be aware of other entities in its federations then MetaMeta may be useful to you.

Features include:

* Ready-to-use configurations and information for all major SAML federations (not complete yet)
* Efficient download, caching and expiry of metadata, using ETag, Expires, Cache-Control and Last-Modified headers where available
* Validation of metadata (also not complete but we're working on it)
* Immediate access to metadata as XML or parsed Nokogiri documents
* Conversion of metadata into convenient Ruby objects for Federations, Entities, Contacts and Organisations.
* Easy storage of objects into databases for querying
* Compatibility with JRuby and Java scripting - may be included in IDPs and Java applications
* Easy integration with non-Ruby applications: MetaMeta will act as a loader to build databases of entities for use by your Java, .Net, Python or PHP application.

## CAVEATS

MetaMeta is still early in development, so please bear the following in mind when using it:

* The API may not be stable until version 1.0. If using Bundler please lock the version to avoid upgrades breaking your application
* Full validation of metadata is not present yet
* The mock 'dev' metadata is not valid or complete. We plan to eventually build some fully-functional example federations, but at present both UnCommon and Example federations are simple test mocks of certain parts of SAML2 metadata.
* The source list of federations is _far_ from complete.
* For development and testing the provided lists should be fine but please DO NOT use the provided federation source lists in production without manually checking their contents or using your own edited version. Your federation will have its own guidelines for verifying their certificate and metadata, please read them and check that the certificate and source URL you are using are correct. Your chain of trust should not originate in a file on Github, even if the creators are nice people.
* MetaMeta is using far too much memory when processing metadata XML. 
* MetaMeta is not compatible with JRuby yet (but we hope it will be) 

## INSTALLATION

If you use RubyGems directly then simply type:

```sh
gem install shibkit-meta_meta
```

and require the gem in your code

```ruby
require 'shibkit/meta_meta'
```

Bundler users can add MetaMeta to their Gemfiles like this:

```ruby
source "http://rubygems.org"
gem "shibkit-meta_meta"
```

then of course run `bundle install` on the commandline and
 `require 'bundler'` within your code.


## USAGE

### Convenience Features

The MetaMeta class provides a number of simple factory-style methods to return
simplified representations of data with SAML metadata files.

#### Automatic metadata retrieval and parsing

MetaMeta contains information about a number of popular federations which it 
will access by default. While it's best to use your own list of sources, it be 
convenient to get started immediately.

For instance, to find the longest entity URI in all popular federations all you
need is:

```ruby
puts Shibkit::MetaMeta.entities.sort!{|a,b| a.uri.size <=> b.uri.size}.last
```

Metadata will normally be downloaded, cached, parsed and sorted on first use. 

#### Easy access to Federation, Entities and Organisations
MetaMeta can return arrays of all federations, and all entities (SPs and IDPs),
IDPs or SPs in all Federations. It can also attempt to list all organisations but
the data returned is not yet particularly useful. 

```ruby
Shibkit::MetaMeta.federations.each {|f| puts f }
Shibkit::MetaMeta.entities.each { |e| puts e }
Shibkit::MetaMeta.idps.each { |e| puts e }
Shibkit::MetaMeta.sps.each { |e| puts e }
Shibkit::MetaMeta.orgs.each { |o| puts o }
```

#### Select an entity by URI
If you already know the URI of an entity in a loaded federation then you can get it directly using
`#from_uri`.

```ruby
entity = Shibkit::MetaMeta.from_uri('https://shib.manchester.ac.uk/shibboleth')

puts entity.idp?         
puts entity.accountable? 
```

Read more about the Shibkit::MetaMeta class

### Metadata Sources

MetaMeta needs to know various things about a Federation before it can access
its metadata. This information is handled by the Source class. Sources can be
specified directly in your code or loaded from a source list file.

Source objects describe federations and collections and are effectively metadata
about metadata, hence the name of this software.

#### Loading your own source list
It's best to write and load your own source list for your software.

* You can download and process only the federations you require, saving time and
energy.
* You can check that file locations, certificates and fingerprints are correct
* You can include your own federations or simpler local metadata collections 

Source lists are simple YAML documents. Copy the examples included with MetaMeta
or read the Shibkit::MetaMeta::Source documentation before writing your own.

```ruby
Shibkit::MetaMeta.sources_file = '/etc/mm/my_metadata_sources.yml'
Shibkit::MetaMeta.idps.each { |e| puts e }
```

#### Selecting a built-in source list
MetaMeta comes with a few source lists that you can choose from.

 * `:real` is a list of all major federations (this file may not be complete yet!)
 * `:dev`  is a small list of tiny fictional federations for testing and development

They are loaded by specifying the symbol instead of a real filename string

```ruby
Shibkit::MetaMeta.sources_file = :real
Shibkit::MetaMeta.idps.each { |e| puts e }
```

## Accessing Source information
Source objects can be accessed directly, to be read or adjusted after loading.

```ruby
## List homepages specified in all metadata sources, wherever the source is defined
Shibkit::MetaMeta.sources.each {|s| puts s.homepage_url}

## All sources loaded from the source list file
Shibkit::MetaMeta.loaded_sources.each {|s| puts s.uri}

# All sources added by hand
Shibkit::MetaMeta.additional_sources.each {|s| puts s.uri}
```

#### Automatic selection of source lists
By default MetaMeta will choose a (hopefully) suitable source list for you. 

(At the moment this is always the `:real` list but when the `:dev` list is fixed this will
be used instead when in 'development' mode in Rails and Sinatra applications)

#### Automatic loading and processing of Metadata
MetaMeta will normally load and process XML from your sources when you first 
ask for data. However, this can sometimes cause delays exactly when you don't want them.

Autoloading of metadata can be turned off and on at any time:

```ruby
Shibkit::MetaMeta.autoload = false
# or maybe
Shibkit::MetaMeta.autoload = true if Date.today.day == 1 
```

Of course if autoloading is turned off you'll not get any federations or entities
when you need them. To load data call the `#load_sources` method:

```ruby
Shibkit::MetaMeta.load_sources    # Loads sources file but not actual metadata
Shibkit::MetaMeta.process_sources # Downloads and processes metadata into objects

# There will now be a delay while metadata is downloaded and processed...

Shibkit::MetaMeta.loaded_sources? # => true
Shibkit::MetaMeta.stocked? # => true
```

You can call `Shibkit::MetaMeta.process_sources`  to pre-emptively create objects
even if `Shibkit::MetaMeta.autoload` is active.

#### Adding your own Sources without a sources file

It's possible to append additional sources using the `Shibkit::MetaMeta.add_source`
method. Pass either a hash or a Source object you prepared earlier.

If a source with the same ID URI already exists then it will be replaced by the
new one.

```ruby
Shibkit::MetaMeta.add_source({
    :uri           => 'http://ukfederation.org.uk',
    :name          => 'UK Access Management Federation For Education And Research',
    :display_name  => 'UK Access Management Federation',
    :type          => 'federation',
    :countries     => ['gb'],
    :metadata      => 'http://metadata.ukfederation.org.uk/ukfederation-metadata.xml',
    :certificate   => 'http://metadata.ukfederation.org.uk/ukfederation.pem',
    :fingerprint   => '94:7F:5E:8C:4E:F5:E1:69:E7:DF:68:1E:48:AA:98:44:A5:41:56:EE',
    :refeds_info   => 'https://refeds.terena.org/index.php/FederationUkfed',
    :homepage      => 'http://www.ukfederation.org.uk',
    :languages     => ['en-gb', 'en'],
    :support_email => ' service@ukfederation.org.uk',
    :description   => 'A single solution for accessing online resources and services',
})

Shibkit::MetaMeta.additional_sources.each { |s| puts s.display_name }

```

### Federations

#### Loading federation objects ahead of time

#### Filtering and selecting Sources/Federations


Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby

  code       # => 1
  code       # => 2

```

which is nice.


### Entities (IDPs & SPs)

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.

### IDPs

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.

### SPs

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.


### Contacts

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.


### Organisations

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.


### User Interface Info

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.

### Logos

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.

### Discovery Hints

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.


### Advertised Attributes


Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.


### Service Information

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.

### Provisioning Your Application

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.


### Writing Source Lists

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.


### General Options

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.




### Caching Options

Stuff blah:

```ruby
code       # => 1
code       # => 2
```

Also stuff blah:

```ruby
code       # => 1
code       # => 2
```

which is nice.


## BACKGROUND



Text discussing Metadata background reading [Semantic Versioning](http://semver.org/) and uses
[TomDoc](http://tomdoc.org/) for inline documentation.

http://docs.oasis-open.org/security/saml/v2.0/saml-metadata-2.0-os.pdf
http://www.oasis-open.org/committees/download.php/42714/sstc-saml-metadata-ui-v1.0-wd07.pdf


## SHIBKIT 

## CONTRIBUTORS

* Pete Birkinshaw

## LICENSE

Shibkit is copyright (c) 2011, Digital Identity Ltd. It's licensed under the 
Apache License, Version 2.0, which is a lot like the BSD and MIT licenses only
with added cunning bits and extra words for lawyers. It's a permissive license.

See [LICENSE.md](https://github.com/Digital-Identity-Labs/shibkit-meta_meta/blob/master/LICENSE)
for the entire whole license text if you're curious.

## DIGITAL IDENTITY LABS


## CONTRIBUTE

If you'd like to add new features to MetaMeta or even remove feature you hate
then 

https://github.com/Digital-Identity-Labs/shibkit-meta_meta





