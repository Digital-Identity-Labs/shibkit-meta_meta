
require 'httparty'

METADATA_SOURCES = {
  :uk => "http://metadata.ukfederation.org.uk/ukfederation-metadata.xml"
} 

def download_metadata_files(sources=METADATA_SOURCES)

  sources.each_pair do |label, source_url|
  
    md_file = metadata_file(label)
  
    unless File.exists? md_file
      puts "Downloading #{source_url} to #{md_file} as #{label} metadata..."
      open(md_file, 'w') { |f| f << HTTParty.get(source_url).body }

    end

  end  
  
end

def metadata_file(label)
  
  file = "#{::File.dirname(__FILE__)}/../data/metadata_cache/#{label}.xml"
  
  return file
  
end
