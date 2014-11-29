#!/usr/bin/env ruby
require 'bundler/setup'
require 'shibkit/meta_meta'
require 'fileutils'
require 'digest/sha1'
require 'RMagick'
require 'parallel'

federation = 'http://ukfederation.org.uk'

puts "Loading #{federation}..."

Shibkit::MetaMeta.config.autoload = false
Shibkit::MetaMeta.config.only_use([federation])

Shibkit::MetaMeta.from_uri(federation)
Shibkit::MetaMeta.load_sources
Shibkit::MetaMeta.process_sources

base_path = ENV['LOGOPOLIS_DATA_PATH'] || 'out'

Parallel.map(Shibkit::MetaMeta.sps.sort { |a,b| a.sp.logos.count <=> b.sp.logos.count }, :in_threads => 8) do |entity|

  enc_name  = Digest::SHA1.hexdigest(entity.entity_uri)
  dir       = File.join(base_path, enc_name)
  dest_file = File.join(dir, "icon.png")

  print "#{enc_name} = #{entity}: "

  FileUtils.mkdir_p dir

  if entity.sp.logos.empty?

    print "*\n"
    FileUtils.copy('default_icon.png', dest_file)
    next

  end

  logo = entity.sp.logos.sort { |a, b| a.pixels <=> b.pixels }.last

  begin
    print '.'
    tmpfile = logo.download
    image   = Magick::Image.read(tmpfile.path).first
    image   = image.resize_to_fit(90, 60)
    image.write dest_file
    tmpfile.close
  rescue => oops
    print "!  (#{oops.message})\n"
    FileUtils.copy('default_icon.png', dest_file)
    next
  end

  print "\n"

end

