require 'shibkit/meta_meta'


metadata = Shibkit::MetaMeta.new

sources = Shibkit::MetaMeta::Source.load(:real)

sources.each_value { |v| metadata.sources << v }



metadata.sources.each do |source|
  
  source.refresh
  source.parse
  
end

metadata.refresh

metadata.federations.each do |federation|
  
  puts federation.display_name
  puts federation.read_at
  puts federation.metadata_id
  puts federation.entities.count
  
  puts federation.entities.to_yaml
  
  #federation.entities.each do |e|
  
  #puts "----------------------"
  #puts e.entity_uri
  #puts "IDP!" if e.idp?
  #puts "SP!"  if e.sp?
  #puts
    
  #  puts e.display_name
  #  puts e.description
  #  puts e.keywords.join
  #  puts e.info_url
  #  puts e.privacy_url
  #  puts e.ip_blocks
  #  puts e.domains
  #  puts e.geolocation_urls
  #  puts
    
  #end
  
end

metadata.save_cache_file("/Users/pete/Desktop/test_metadata2.yml")
