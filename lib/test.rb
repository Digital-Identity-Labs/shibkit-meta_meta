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
  
end

metadata.save_cache_file("/Users/pete/Desktop/test_metadata2.yml")
