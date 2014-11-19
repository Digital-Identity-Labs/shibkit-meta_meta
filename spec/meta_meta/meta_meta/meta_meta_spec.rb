require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta do
  before(:all) do
    file = File.open("rspec.log",'w')
    Shibkit::MetaMeta.config.logger= Logger.new(file)
    Shibkit::MetaMeta.config.logger.level = Logger::DEBUG
    Shibkit::MetaMeta.config.logger.datetime_format = "%Y-%m-%d %H:%M:%S"
    Shibkit::MetaMeta.config.logger.formatter       = proc { |severity, datetime, progname, msg| "#{datetime}: #{severity} #{msg}\n" }
    Shibkit::MetaMeta.config.logger.progname        = "MetaMeta-RSpec"
  end

 #  before(:each) do |test|
 #    Shibkit::MetaMeta.reset
 #    Shibkit::MetaMeta.config.autoload = true
 #    Shibkit::MetaMeta.config.logger.info "Running [#{test.example.metadata[:full_description]}]"
 #  end
 # after(:each) do |test|
 #    Shibkit::MetaMeta.config.logger.info "Finihed [#{test.example.metadata[:full_description]}]"
 #  end
  
  describe "#reset" do
    it "should reduce the number of sources to zero" do
      Shibkit::MetaMeta.reset
      expect(Shibkit::MetaMeta.additional_sources.size).to eq(0)
      expect(Shibkit::MetaMeta.loaded_sources.size).to eq(0) 
    end
  end

  describe "#add_source" do

    it "should accept a single source" do
      Shibkit::MetaMeta.add_source({
          :uri           => 'http://ukfederation.org.uk',
          :name          => 'UK Access Management Federation For Education And Research',
          :display_name  => 'UK Access Management Federation',
          :type          => 'federation',
          :countries     => ['gb'],
          :metadata      => 'http://metadata.ukfederation.org.uk/ukfederation-metadata.xml',
          :certificate   => 'http://metadata.ukfederation.org.uk/ukfederation.pem',
          :fingerprint   => '94:7F:5E:8C:4E:F5:E1:69:E7:DF:68:1E:48:AA:98:44:A5:41:56:EE',
          :refeds_info   => 'https://refeds.terena.org/index.php/FederationUkfed',
          :homepage      => 'http://www.ukfederation.org.uk',
          :languages     => ['en-gb', 'en'],
          :support_email => ' service@ukfederation.org.uk',
          :description   => 'A single solution for accessing online resources and services',
      })
      expect(Shibkit::MetaMeta.additional_sources.size).to eq(1)
      expect(Shibkit::MetaMeta.additional_sources.first[0]).to eq('http://ukfederation.org.uk')
    end

    it "should accept more than one source" do
      Shibkit::MetaMeta.add_source({
          :uri           => 'http://ukfederation.org.uk',
          :name          => 'UK Access Management Federation For Education And Research',
          :display_name  => 'UK Access Management Federation',
          :type          => 'federation',
          :countries     => ['gb'],
          :metadata      => 'http://metadata.ukfederation.org.uk/ukfederation-metadata.xml',
          :certificate   => 'http://metadata.ukfederation.org.uk/ukfederation.pem',
          :fingerprint   => '94:7F:5E:8C:4E:F5:E1:69:E7:DF:68:1E:48:AA:98:44:A5:41:56:EE',
          :refeds_info   => 'https://refeds.terena.org/index.php/FederationUkfed',
          :homepage      => 'http://www.ukfederation.org.uk',
          :languages     => ['en-gb', 'en'],
          :support_email => ' service@ukfederation.org.uk',
          :description   => 'A single solution for accessing online resources and services',
      })
      Shibkit::MetaMeta.add_source({
          :uri           => 'urn:mace:aaf.edu.au:AAFProduction',
          :name          => 'Australian Access Federation',
          :display_name  => 'AAF',
          :type          => 'federation',
          :countries     => ['au'],
          :metadata      => 'http://manager.aaf.edu.au/metadata/metadata.aaf.signed.complete.xml',
          :certificate   => 'https://manager.aaf.edu.au/metadata/metadata-cert.pem',
          :refeds_info   => 'https://refeds.terena.org/index.php/FederationAAF',
          :homepage      => 'http://www.aaf.edu.au/',
          :languages     => ['en'],
          :support_email => 'enquiries@aaf.edu.au',
          :description   => 'The Australian Access Federation.',
      })
      expect(Shibkit::MetaMeta.additional_sources.size).to eq(2)
      expect(Shibkit::MetaMeta.additional_sources.keys[0]).to eq('http://ukfederation.org.uk')
      expect(Shibkit::MetaMeta.additional_sources.keys[1]).to eq('urn:mace:aaf.edu.au:AAFProduction')
    end

  end

  describe "#save_sources" do
    xit "should save the sources list to a file" do
      Shibkit::MetaMeta.add_source({
          :uri           => 'urn:mace:aaf.edu.au:AAFProduction',
          :name          => 'Australian Access Federation',
          :display_name  => 'AAF',
          :type          => 'federation',
          :countries     => ['au'],
          :metadata      => 'http://manager.aaf.edu.au/metadata/metadata.aaf.signed.complete.xml',
          :certificate   => 'https://manager.aaf.edu.au/metadata/metadata-cert.pem',
          :refeds_info   => 'https://refeds.terena.org/index.php/FederationAAF',
          :homepage      => 'http://www.aaf.edu.au/',
          :languages     => ['en'],
          :support_email => 'enquiries@aaf.edu.au',
          :description   => 'The Australian Access Federation.',
      })
      Shibkit::MetaMeta.add_source({
          :uri           => 'http://ukfederation.org.uk',
          :name          => 'UK Access Management Federation For Education And Research',
          :display_name  => 'UK Access Management Federation',
          :type          => 'federation',
          :countries     => ['gb'],
          :metadata      => 'http://metadata.ukfederation.org.uk/ukfederation-metadata.xml',
          :certificate   => 'http://metadata.ukfederation.org.uk/ukfederation.pem',
          :fingerprint   => '94:7F:5E:8C:4E:F5:E1:69:E7:DF:68:1E:48:AA:98:44:A5:41:56:EE',
          :refeds_info   => 'https://refeds.terena.org/index.php/FederationUkfed',
          :homepage      => 'http://www.ukfederation.org.uk',
          :languages     => ['en-gb', 'en'],
          :support_email => ' service@ukfederation.org.uk',
          :description   => 'A single solution for accessing online resources and services',
      })
      tmpfile = Tempfile.new('metametasources')
      sourcesfile = tmpfile.path
      sourcesfile = 'mysaved_sources.yaml'
      tmpfile.close
      Shibkit::MetaMeta.save_sources(sourcesfile)
      referencefile = File.open("#{File.dirname(__FILE__)}/saved_sources.yaml").read
      resultfile = File.open(sourcesfile).read
      Shibkit::MetaMeta.config.logger.debug "referencefile (MD5:#{Digest::MD5.hexdigest(referencefile)}):\n#{referencefile}\nsavedfile (MD5:#{Digest::MD5.hexdigest(resultfile)}):\n#{resultfile}\n"
      expect(File.exists? sourcesfile).to eq(true)
      expect(resultfile).to eq(referencefile)
    end
  end
  describe "#load_sources" do
    xit "should automatically load sources if no source file has been specified." do
      Shibkit::MetaMeta.load_sources
      expect(Shibkit::MetaMeta.loaded_sources.size).to eq(4)
      expect(Shibkit::MetaMeta.loaded_sources?).to eq(true)
      expect(Shibkit::MetaMeta.loaded_sources.keys[0]).to eq('http://ukfederation.org.uk')
    end
    it "should be possible to set the file to load from" do
      Shibkit::MetaMeta.config.sources_file="#{File.dirname(__FILE__)}/saved_sources.yaml"
    end
    it "should load sources from a file" do
      Shibkit::MetaMeta.config.sources_file="#{File.dirname(__FILE__)}/saved_sources.yaml"
      Shibkit::MetaMeta.load_sources
      expect(Shibkit::MetaMeta.loaded_sources.size).to eq(2)
      expect(Shibkit::MetaMeta.loaded_sources?).to eq(true)
      expect(Shibkit::MetaMeta.loaded_sources.keys[1]).to eq('http://ukfederation.org.uk')
      expect(Shibkit::MetaMeta.loaded_sources.keys[0]).to eq('urn:mace:aaf.edu.au:AAFProduction')
    end
  end

  
  describe "#process_sources" do
    it "should read it's sources and return an array of federation objects" do
      federations = Shibkit::MetaMeta.process_sources
      expect(federations.is_a?(Array)).to eq(true)
      expect(federations.size).to be > 0
      federations.each {|fed| expect(fed.is_a?(Shibkit::MetaMeta::Federation)).to eq(true)}
    end
  end
  describe "#save_cache_file" do
    it "should save the federation cache to a file" do
      federations = Shibkit::MetaMeta.process_sources
      tmpfile = Tempfile.new('metametacache')
      cachefile = tmpfile.path
      Shibkit::MetaMeta.save_cache_file(cachefile)
      expect(File.exists? cachefile).to eq(true)
    end
  end
  describe "#load_cache_file" do
    it "should load objects from a cache file" do
      Shibkit::MetaMeta.load_cache_file("#{File.dirname(__FILE__)}/cache_example.yaml")
      expect(Shibkit::MetaMeta.stocked?).to eq(true)
    end 
  end
  describe "#flush" do
    it "should clear the cache" do
      Shibkit::MetaMeta.load_cache_file("#{File.dirname(__FILE__)}/cache_example.yaml")
      expect(Shibkit::MetaMeta.stocked?).to eq(true)
      Shibkit::MetaMeta.flush
      expect(Shibkit::MetaMeta.stocked?).to eq(false)
    end
  end
  describe "#delete_all_cached_files" do
    it "should prevent me from accidentally harming my system"
    it "should delete cache file"
  end
  describe "#smart_cache" do
    it "should do 'something smart'"
  end
  describe "#refresh" do
    it "should refresh metadata" do
      Shibkit::MetaMeta.refresh
      Shibkit::MetaMeta.stocked?
    end
    it "shouldn't refresh, (under certain conditions)"
    it "should be forcable"
  end
  describe "#stockup" do
    it "should load sources, if it is configured to auto-load" do
      Shibkit::MetaMeta.config.autoload = true
      Shibkit::MetaMeta.stockup
      expect(Shibkit::MetaMeta.stocked?).to eq(true)
    end
    xit "shouldn't do anything if it isn't configured to auto-load" do
      Shibkit::MetaMeta.config.autoload = false
      Shibkit::MetaMeta.stockup
      expect(Shibkit::MetaMeta.stocked?).to eq(false)
    end
    it "shouldn't load sources if federations have already been loaded"
  end
  describe "#federations" do
    it "should auto-initilize" do
      Shibkit::MetaMeta.federations
      expect(Shibkit::MetaMeta.stocked?).to eq(true)
    end
    it "should return a array of Shibkit::Federation objects" do
      feds = Shibkit::MetaMeta.federations
      expect(feds.is_a?(Array)).to eq(true)
      expect(feds.size).to be > 0
      feds.each {|fed| expect(fed.is_a?(Shibkit::MetaMeta::Federation)).to eq(true)}
    end
  end
  describe "#entities" do
    it "should return an array of Shibkit::Entity objects" do
      ents = Shibkit::MetaMeta.entities
      ents.is_a?(Array)
      expect(ents.size).to be > 0
      ents.each {|ent| expect(ent.is_a?(Shibkit::MetaMeta::Entity)).to eq(true)}
    end
  end
  describe "#orgs" do
    it "should return an array of Shibkit::Organisation objects, sorted by druid" do
      orgs = Shibkit::MetaMeta.orgs
      orgs.is_a?(Array)
      expect(orgs.size).to be > 0
      orgs.each {|org| expect(org.is_a?(Shibkit::MetaMeta::Organisation)).to eq(true)}
    end
  end
  describe "#idps" do
    it "should return an array of Shibkit::IDP objects" do
      idps = Shibkit::MetaMeta.idps
      idps.is_a?(Array)
      expect(idps.size).to be > 0
      Shibkit::MetaMeta.config.logger.debug "IDP Array:"
      idps.each {|idp| 
        Shibkit::MetaMeta.config.logger.debug "  object type:#{idp.class}"
        expect(idp.is_a?(Shibkit::MetaMeta::Entity)).to eq(true)
        expect(idp.idp?).to eq(true)
      }
    end
  end
  describe "#sps" do
    it "should return an array of Shibkit::SP objects" do
      sps = Shibkit::MetaMeta.sps
      sps.is_a?(Array)
      expect(sps.size).to be > 0
      Shibkit::MetaMeta.config.logger.debug "SP Array:"
      sps.each {|sp| 
        Shibkit::MetaMeta.config.logger.debug "  object type:#{sp.class}"
        expect(sp.is_a?(Shibkit::MetaMeta::Entity)).to eq(true)
        expect(sp.sp?).to eq(true)
      }
    end
  end
  describe "#from_uri" do
    # TODO I don't know what this is for
  end
end
