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
  
  #puts federation.entities.to_yaml
  
  federation.entities.each do |e|
  
  puts "----------------------"
  #puts e.entity_uri
  #puts "IDP!" if e.idp?
  #puts "SP!"  if e.sp?
  #puts
  
  if e.idp?
  puts e.idp.display_name
  puts e.idp.description
  puts e.idp.keywords.join
  puts e.idp.info_url
  puts e.idp.privacy_url
  puts e.idp.ip_blocks
  puts e.idp.domains
  puts e.idp.geolocation_urls
  puts e.organisation.name
  puts e.idp.attributes.join(';')
  puts e.idp.protocols.join(';')
  puts e.idp.nameid_formats.join(';')
  puts e.scopes.join(';')
  puts e.idp.scopes.join(';')
  end
    
  end
  
end

metadata.save_cache_file("/Users/pete/Desktop/test_metadata2.yml")
