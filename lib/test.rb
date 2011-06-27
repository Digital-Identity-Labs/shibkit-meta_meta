require 'shibkit/meta_meta'

config = {"Example Federation"  => "shibkit/data/default_metadata/example_federation_metadata.xml",
          "UnCommon"            => "shibkit/data/default_metadata/uncommon_federation_metadata.xml",
          "Other Organisations" => "shibkit/data/default_metadata/local_metadata.xml"}

metadata = Shibkit::MetaMeta.new

config.each_pair do |name, file|
  metadata.add_source name, file
end

metadata.refresh

metadata.federations.each do |federation|
  
  puts federation.display_name
  puts federation.read_at
  puts federation.metadata_id
  puts federation.entities.count
  
  puts federation.entities.to_yaml
  
end

metadata.save_cache_file("/Users/pete/Desktop/test_metadata2.yml")
