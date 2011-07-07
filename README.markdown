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

## INSTALLATION

If you use RubyGems directly then simply type:

    $ [sudo] gem install shibkit-meta_meta

Bundler users can add MetaMeta to their Gemfiles like this:

then of course run bundle install

## CONVENIENCE FEATURES

Stuff blah:

    code

Also stuff blah:

    code

which is nice.

## METADATA SOURCES

Stuff blah:

    code

Also stuff blah:

    code

which is nice.

## FEDERATIONS

Stuff blah:

    code

Also stuff blah:

    code

which is nice.

## ENTITIES (IDP/SP)

Stuff blah:

    code

Also stuff blah:

    code

which is nice.


## CONTACTS

Stuff blah:

    code

Also stuff blah:

    code

which is nice.



## ORGANISATIONS

Stuff blah:

    code

Also stuff blah:

    code

which is nice.



## WRITING SOURCE LISTS

Stuff blah:

    code

Also stuff blah:

    code

which is nice.



## OPTIONS

Stuff blah:

    code

Also stuff blah:

    code

which is nice.



## CACHING OPTIONS

Stuff blah:

    code

Also stuff blah:

    code

which is nice.


## BACKGROUND



Text discussing Metadata background reading [Semantic Versioning](http://semver.org/) and uses
[TomDoc](http://tomdoc.org/) for inline documentation.

http://www.oasis-open.org/committees/download.php/42714/sstc-saml-metadata-ui-v1.0-wd07.pdf

## SHIBKIT 

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





