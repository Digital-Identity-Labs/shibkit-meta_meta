require 'shibkit/meta_meta'




#######

Shibkit::MetaMeta.reset

#Shibkit::MetaMeta.sources_file = :dev # Normally automatic


Shibkit::MetaMeta.add_source({
    :uri => 'http://ukfederation.org.uk',
    :name => ' UK Access Management Federation For Education And Research',
    :display_name => ' UK Access Management Federation',
    :type => 'federation',
    :countries => ['gb'],
    :metadata => 'http://metadata.ukfederation.org.uk/ukfederation-metadata.xml',
    :certificate => 'http://metadata.ukfederation.org.uk/ukfederation.pem',
    :fingerprint => '',
    :refeds_info => 'https://refeds.terena.org/index.php/FederationUkfed',
    :homepage => 'http://www.ukfederation.org.uk',
    :languages => ['en-gb', 'en'],
    :support_email => ' service@ukfederation.org.uk',
    :description => 'A single solution for accessing online resources and services',
})       

Shibkit::MetaMeta.only_use('http://ukfederation.org.uk')

Shibkit::MetaMeta.sources

Shibkit::MetaMeta.refresh




Shibkit::MetaMeta.federations.each {|f| puts f.uri }

Shibkit::MetaMeta.entities.each { |e| puts e.uri }

Shibkit::MetaMeta.idps.each { |e| puts e.uri }

Shibkit::MetaMeta.sps.each { |e| puts e.uri }

Shibkit::MetaMeta.orgs.each { |e| puts e.uid }


exit

sources = Shibkit::MetaMeta::Source.load(:real)

#sources['urn:mace:incommon'].read.each do |node|
  
 # next unless node.name == "EntityDescriptor"
#  puts node.name
#  puts node.class
  
#end

#exit

sources.each_value { |v| metadata.sources << v }

metadata.sources.each do |source|
  
  source.refresh
  #source.parse
  
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

  if e.sp?
    puts "SP..."
    puts e.sp.display_name
    puts e.sp.description
    if e.sp.default_service
      puts e.sp.default_service.attributes.inspect
    end
    puts e.sp.protocols.join(';')

    
  end
    
  end
  
end

#metadata.save_cache_file("/Users/pete/Desktop/test_metadata2.yml")
