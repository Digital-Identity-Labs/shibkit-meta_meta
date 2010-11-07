require 'shibkit/metameta'

config = {"Example Federation"  => "/data/default_metadata/example_federation_metadata.xml".to_absolute_path,
          "UnCommon"            => "/data/default_metadata/uncommon_federation_metadata.xml".to_absolute_path,
          "Other Organisations" => "/data/default_metadata/local_metadata.xml".to_absolute_path}

metadata = Shibkit::MetaMeta.new

config.each_pair do |name, file|
  metadata.add_source name, file
end

puts metadata.inspect


metadata.refresh

metadata.federations.each do |federation|
  
  puts federation.display_name
  puts federation.read_at
  puts federation.metadata_id
  puts federation.entities.count
  
end

metadata.save_cache_file("/Users/pete/Desktop/test_metadata2.yml")
