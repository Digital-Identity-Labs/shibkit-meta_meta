Shibkit::MetaMeta - Lazy Access To SAML Metadata
================================================

## DESCRIPTION

Shibkit::MetaMeta aims to provide lazy, friendly handling of
Shibboleth/SAML2 metadata. Easily download and parse metadata XML into Ruby
objects. 

### What is SAML Metadata? What is Shibboleth?
SAML2 Metadata is widely used in education to build access management federations
- groups of trusted IDPs (login servers) and SPs (websites using the IDPs for authentication). 

MetaMeta is the first part of Shibkit to be released. It does not require any
of the other Shibkit gems to work but most of the others depend on it.

### Why use Shibkit::MetaMeta?

There are few reasons to use MetaMeta if you are running an IDP or a simple
authenticated website. However, if you are building a more advanced web application
that needs to be aware of other entities in its federations then MetaMeta may be useful to you.

Features include:

* Ready-to-use configurations and information for all major SAML federations (not actually complete yet)
* Efficient download, caching and expiry of metadata, using ETag, Expires, Cache-Control and Last-Modified headers where available
* Validation of metadata (also not complete but we're working on it)
* Immediate access to metadata as XML or parsed Nokogiri documents
* Conversion of metadata into convenient Ruby objects for Federations, Entities, Contacts and Organisations.
* Easy storage of objects into databases for querying
* Compatibility with JRuby and Java scripting - it may then be included in Java IDPs and other Java applications (not working yet)
* Easy integration with non-Ruby applications: MetaMeta will act as a loader to build databases of entities for use by your Java, .Net, Python or PHP application.

### Shibkit::Disco

Shibkit::MetaMeta provides a simple interface to data stored in SAML metadata files
but does not include any persistence or query facilities, discovery protocol support, etc.

If you are planning to use SAML metadata within your application you might be better
using Shibkit::Disco, a library that builds on Shibkit::MetaMeta to provide a 
SAML discovery framework. Most features of Shibkit::MetaMeta will still be available inside
Shibkit::Disco.

>I feel the same way about disco as I do about herpes. 
>*Hunter S. Thompson*
  
If you don't fancy the heavier framework in Shibkit::Disco you can probably get
what you need from Shibkit::MetaMeta, or use it in a framework of your own.

## CAVEATS

MetaMeta is still early in development so please bear the following in mind when using it:

* Tests and API documentation are not complete. They will be completed before version 1.0.0.
* The API may not be stable until version 1.0. If using Bundler please lock the version to avoid upgrades breaking your application
* Full validation of metadata is not present yet. **Do not use MetaMeta for security checks yet.**
* The mock 'dev' metadata is not valid or complete. We plan to eventually build some fully-functional example federations, but at present both UnCommon and Example federations are simple test mocks of certain parts of SAML2 metadata.
* The source list of federations is _far_ from complete.
* For development and testing the provided lists should be fine but please DO NOT use the provided federation source lists in production without manually checking their contents or using your own edited version. Your federation will have its own guidelines for verifying their certificate and metadata, please read them and check that the certificate and source URL you are using are correct. Your chain of trust should not originate in a file on Github, even if the creators are nice people.
* MetaMeta is using far too much memory when processing metadata XML. 
* MetaMeta is not compatible with JRuby yet (but we hope it will be)
* Not yet tested on Windows, although it detects Windows and tries to compensate.

## INSTALLATION

### As a released Ruby Gem

#### Rubygems

If you use RubyGems directly then simply type:

```bash
gem install shibkit-meta_meta
```

and require the gem in your code

```ruby
require 'shibkit/meta_meta'
```

#### Bundler

Bundler users can add MetaMeta to their Gemfiles like this:

```ruby
source "http://rubygems.org"
gem "shibkit-meta_meta"
```

then of course run `bundle install` on the commandline and
 `require 'bundler'` within your code.

It's a very good idea to immediately specify a gem version since MetaMeta is
going to a little unstable for awhile, and there may be breaking-things API
changes until v1.0.0. 

### Using the latest development version
If you'd like to use the very latest in-development version of MetaMeta, possibly
as a developer you should check it out of Github and include it with Bundler by specifying
the source location:

```bash
git clone git@github.com:Digital-Identity-Labs/shibkit-meta_meta.git
```

```ruby
source "http://rubygems.org"
gem "shibkit-meta_meta", :path => "~/Projects/shibkit-meta_meta/"
```

Please feel welcome to fork the project on Github and send pull requests for any
changes you wish to contribute.

## USAGE

### Convenience Features

The MetaMeta class provides a number of simple factory-style methods to return
simplified representations of the items within SAML metadata files.

#### Automatic metadata retrieval and parsing

MetaMeta contains information about a number of popular federations which it 
will access by default. While it's best to use your own list of sources, it be 
convenient to get started immediately.

For instance, to find the longest entity URI in all popular federations all you
need is:

```ruby
puts Shibkit::MetaMeta.entities.sort!{|a,b| a.uri.size <=> b.uri.size}.last
```

Metadata will normally be automatically downloaded, cached, parsed and sorted on first use. 

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

----

### Metadata Sources

MetaMeta needs to know various things about a Federation before it can access
its metadata. This information is handled by the Source class. Sources can be
specified directly in your code or loaded from a source list file.

Source objects describe federations and collections and are effectively metadata
about metadata, hence the odd name of this software.

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

----

### Accessing Source information
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

----

### Federations

Federation objects describe a federation, including its members 
(SPs and IDPs). 

#### Listing federation objects

You can get an array of all loaded federations using '#federations'

```ruby
all_federations = Shibkit::MetaMeta.federations 
```

#### Finding an federation by URI

```ruby
uk_fed = Shibkit::MetaMeta.from_uri('http://ukfederation.org.uk')
```

#### Loading federation objects ahead of time

Calling `Shibkit::MetaMeta.process_sources` will re-process federation metadata
into objects, removing previously generated objects from MetaMeta's lists.

```ruby
Shibkit::MetaMeta.process_sources 
Shibkit::MetaMeta.stocked? # => true
```

#### Filtering and selecting Sources/Federations

It's nice to have easy access to many different federations but if you're only
interested in one or two of them it can add a lot of wasteful overhead to process
all of them together.

You can limit the sources/federations to be processed using the `#only_use` method:

```ruby
Shibkit::MetaMeta.only_use(['http://ukfederation.org.uk'])

```

After specifying federation URIs only matching federations will be processed.

You can go back to processing all federations by using `:all` or `:everything`

```ruby
Shibkit::MetaMeta.only_use(:everything)

```

----

### Entities (IDPs & SPs)

Entity objects are generic representations of entities listed in SAML metadata.
They can be IDPs, SPs, or both. MetaMeta only stores general information about the
entity in the Entity object itself, and then uses SP and IDP objects inside it
to store more detailed information about the roles of the entity.

#### Accessing all the entities in a federation

```ruby
federation = Shibkit::MetaMeta.from_uri('http://ukfederation.org.uk')
uk_fed_entities = federation.entities
```

#### Finding an entity by URI

```ruby
uom_idp = Shibkit::MetaMeta.from_uri('https://shib.manchester.ac.uk/shibboleth')
```

#### Listing all primary entities in all federations
If you're read this far you can probably guess how this will go.

```ruby
all_entities = Shibkit::MetaMeta.entities
```

This doesn't list *all* entities, only all *primary* entities. I'm afraid we've made
up the term "primary entity". Read on for enlightenment.

#### Multi-federation entities and primary entities

The same IDP or SP, represented by the same URI, can be in more than one federation.
The Shibboleth IDP will load the only the first one that it finds. Because of this,
although it's possible to give the same service different metadata in each
federation it's probably a bad idea to do so - you don't know which metadata
for your service will be used.

IDPs and SPs don't usually care which trusted federation an entity belongs to - they're
trusted, and that's what matters. However, your SAML-aware software might care, so
MetaMeta tries to keep track of multiple federation membership.

Each Federation object has its own list of entities. These are separate objects and if
metadata for a service varies between different federations it should be different
between their MetaMeta objects too.

```ruby
entity1 = fed1.entities.collect { |e| e.uri = 'http://silly-idp.com/shib' }[0]
entity2 = fed2.entities.collect { |e| e.uri = 'http://silly-idp.com/shib' }[0]

entity1.primary_federation_uri # => 'http://fed1.org'
entity1.idp.protocols
  # => ['urn:oasis:names:tc:SAML:1.1:protocol', 'urn:oasis:names:tc:SAML:2.0:protocol']

entity2.primary_federation_uri # => 'http://fed2.org'
entity2.idp.protocols
  # => ['urn:oasis:names:tc:SAML:2.0:protocol']

```

In most cases you don't want to know about the other varieties; you want to know about
the entity with the first metadata to be loaded. Shibkit::MetaMeta refers to this
as the "Primary Entity", and its parent Federation as its "primary federation".

Shibkit::MetaMeta only lists primary records when you call `Shibkit::MetaMeta.from_uri` and
`Shibkit::MetaMeta.entities`

Primary entities will have any other federations that they are a member of listed under 
`#other_federations` and `#secondary_federations`. Both primary and seconday/other federations are
listed by `#federation_uris`. 

You can quickly check if an entity is primary or multifederation:

```ruby
ent = Shibkit::MetaMeta.from_uri('https://idp.uni.ac.uk/shibboleth')

ent.primary? # => true
ent.multi_federated? # => true
```

#### Entity objects

```ruby
ent = Shibkit::MetaMeta.from_uri('https://idp.uni.ac.uk/shibboleth')

ent.uri # => 'https://idp.uni.ac.uk/shibboleth'
ent.accountable? # => true
ent.hide?        # => false
ent.sp?          # => false
ent.idp?         # => true

ent.idp.scopes # => ['uni.ac.uk']

```

For more information on Entity objects please read the API documentation.

----

### IDPs

While an Entity object can represent an IDP (indicated by the `#idp?` method) the details of its
IDP role are held in the IDP object it contains.

```ruby
entity.idp? # => true
entity.idp.protocols        # => ['urn:oasis:names:tc:SAML:2.0:protocol']
entity.idp.scopes           # => ['uni.ac.uk']

entity.idp.display_name     # => "The University of Studies"
entity.idp.display_name :fr # => "L'Université des Etudes"
entity.idp.description      # => "Example login service for UoS"  
entity.idp.domains          # => ['uni.ac.uk']
```

For more information on IDP objects please read the API documentation.

----


### SPs

Entity objects can also represent an SP (even if also an IDP). As with IDPs the
additional information is represented by an SP object within the Entity object.

```ruby
entity.sp? # => true
entity.sp.protocols     # => ['urn:oasis:names:tc:SAML:2.0:protocol']

entity.sp.display_name     # => "University of Studies Webmail"
entity.sp.display_name :fr # => "L'Université des Etudes de Webmail"
entity.sp.description      # => "Email service for staff and students"  
entity.sp.ip_blocks        # => ['192.168.1.0/24', '10.50.1.0/24']
```

For more information on SP objects please read the API documentation.

----

### Contacts

IDP and SP objects may contain Contact objects. Each type of contact is available 
from its own method in an Entity object. If a contact type is not available then `nil`
is returned.

```ruby
sc = entity.support_contact
tc = entity.technical_contact
ac = entity.admin_contact
```

Contact objects are very simple:

```ruby
contact = entity.support_contact

contact.givenname     # => 'Joe'
contact.surname       # => 'Yossarian'
contact.display_name  # => 'Joe Yossarian'
contact.email_url     # => "mailto:joe.yossarian@uni.ac.uk"
contact.email_address # => 'joe.yossarian@uni.ac.uk'
contact.category      # => :support

```

For more information on Contact objects please read the API documentation.

----

### Organisations

IDP and SP objects may contain Organisation objects. Organisation details have 
often been used to describe services (especially IDPs) rather than the organisation
running the service. Recent additions to SAML metadata (described in the next section) will
hopefully lead to organisation details gradually becoming more useful.

```ruby
org = entity.organisation

org.name          # => 'University of Studies'
org.display_name  # => 'University of Studies IDP (test)'
org.url           # => 'uni.ac.uk' 
```

MetaMeta will fall back to using Organisation data to describe entities when no
user interface information is available.

The `Shibkit::MetaMeta.orgs` method will list all organisations found in all federations
after trying, rather badly, to minimise repeated records. We added this feature to 
see how well it would work, and so far it doesn't work very well at all.

For the curious or optimistic:

```ruby
messy_list_organisations = Shibkit::MetaMeta.orgs
```

----

### User Interface Info

Shibkit::MetaMeta aims to reproduce the details that Shibboleth IDPs can present 
to users during authentication - friendly, localised information on SPs and IDPs.

User interface information for SPs and IDPs is available as as English default, a 
specified locale (if available, falling back to English) and as a hash of all available
content.

```ruby
entity.idp.display_name     # => "The University of Studies"
entity.idp.display_name :fr # => "L'Université des Etudes"
entity.idp.display_names  
  # => {:en => "The University of Studies", :fr => "L'Université des Etudes"}

entity.idp.keywords      # => ['example', 'university']
entity.idp.keywords :fr  # => ['exemple', 'université']
entity.idp.keyword_sets  
  # => {:en => ['example', 'university'], :fr => ['exemple', 'université']}
```

----

### Logos

SPs and IDPs may also have Logo objects, for use in user interfaces or just to
decorate your federation reports. Like user interface information they can be 
grouped according to language, and the defaults assume `:en`

```ruby
default_logos = entity.idp.logos
french_logos  = entity.idp.logos :fr

default_logos.each { |logo| puts logo.url ; puts logo.width }

## Find location of largest image in a set
french_logos.sort{ |a,b| a.pixels <=> b.pixels }.last.uri

```

Logo objects have various methods for describing the image, downloading it,
comparing the real image to details in metadata, etc. Please read the API docs
for more info.  

----

### Discovery Hints

Discovery hints can be used by WAYF/Discovery Services to guess at likely
options for users.

```ruby
entity.sp.ip_blocks          # => ['192.168.1.0/24', '10.50.1.0/24']
entity.sp.domains            # => ['uni.ac.uk']
entity.idp.geo_location_uris # => nil 
```

----


### Service Information
SPs can advertise a number of Services.

...

### IDP and SP Attributes
While rarely used, it's possible for metadata to list the attributes made available
by IDPs or requested by SPs. These should be available via the SP and IDP objects.

```ruby
entity.idp.attributes.each { |a| puts a.friendly_name }

entity.sp.default_service.attributes.each { |a| puts a.name }

```

----

### Provisioning Your Application

Shibkit::MetaMeta is **not** a sleek and speedy bit of software. It can use a
fairly large amount of RAM to process metadata - when loading four federations
(c.2400 unique entities) a couple of hundred megabytes of RAM is typical,
and also takes about a minute on a typical PC. 

Because of this it is probably a very bad idea to autoload objects inside a 
persistent web application, especially at startup. Using multiple Mongrel processes,
each loading their own metadata, is definitely not advisable. 

Shibkit::MetaMeta is best suited to running scripts that process metadata then quit,
maybe loading data into other storage formats.

If you want a persistent database to query within your applications you should
consider Shibkit::Disco, which builds on MetaMeta and provides a variety of database
backends.

----

### General Options

...

----

### Caching Options

...

## BACKGROUND READING

...


## SHIBKIT 

...

## CONTRIBUTORS

* Pete Birkinshaw
* Eddy Wheldon
* Linda Ward
* Sam Jones

## LICENSE

Shibkit is copyright (c) 2011, Digital Identity Ltd. It's licensed under the 
Apache License, Version 2.0, which is a lot like the BSD and MIT licenses only
with added cunning bits and extra words for lawyers. It's a permissive license.

See [LICENSE.md](https://github.com/Digital-Identity-Labs/shibkit-meta_meta/blob/master/LICENSE)
for the entire whole license text if you're curious.

## DIGITAL IDENTITY LABS

...

## OOPS...

We've definitely made mistakes. This is software - there are going to be coding bugs,
inaccurate documentation, misinterpreted specs, and horrible, embarrassing things that
we haven't even worried about yet.

If you find something wrong, weird or confusing please let us know on the Shibkit-MetaMeta
issue tracker. It might cause us blushes but we'd rather someone let us know straight away.

https://github.com/Digital-Identity-Labs/shibkit-meta_meta/issues

## CONTRIBUTE

If you'd like to add new features to MetaMeta or even remove feature you hate
then please fork the repository on Github. Change the code to work the way you want,
and then send us a pull request if you'd like us to merge any of your changes back
into the official repository.

https://github.com/Digital-Identity-Labs/shibkit-meta_meta

If you'd like us to add a feature for you then please get in touch.



