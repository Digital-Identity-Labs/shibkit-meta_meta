require 'rubygems'
require 'shibkit/meta_meta'

puts Shibkit::MetaMeta.entities.sort!{|a,b| a.uri.size <=> b.uri.size}.last 
