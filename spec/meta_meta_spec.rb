require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'digest/md5'

describe Shibkit::MetaMeta do
  before(:all) do
    file = File.open("rspec.log",'w')
    Shibkit::MetaMeta.config.logger= Logger.new(file)
    Shibkit::MetaMeta.config.logger.level = Logger::DEBUG
    Shibkit::MetaMeta.config.logger.datetime_format = "%Y-%m-%d %H:%M:%S"
    Shibkit::MetaMeta.config.logger.formatter       = proc { |severity, datetime, progname, msg| "#{datetime}: #{severity} #{msg}\n" }
    Shibkit::MetaMeta.config.logger.progname        = "MetaMeta-RSpec"
  end

  before(:each) do |test|
    Shibkit::MetaMeta.reset
    Shibkit::MetaMeta.config.logger.info "Running [#{test.example.metadata[:full_description]}]"
  end
 after(:each) do |test|
    Shibkit::MetaMeta.config.logger.info "Finihed [#{test.example.metadata[:full_description]}]"
  end
  
  describe "#reset" do
    it "should reduce the number of sources to zero" do
      Shibkit::MetaMeta.reset
      Shibkit::MetaMeta.additional_sources.size.should == 0 &&
      Shibkit::MetaMeta.loaded_sources.size.should == 0 
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
      Shibkit::MetaMeta.additional_sources.size.should == 1 &&
      Shibkit::MetaMeta.additional_sources.first[0].should == 'http://ukfederation.org.uk'
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
      Shibkit::MetaMeta.additional_sources.size.should == 2 &&
      Shibkit::MetaMeta.additional_sources.keys[0].should == 'http://ukfederation.org.uk' &&
      Shibkit::MetaMeta.additional_sources.keys[1].should == 'urn:mace:aaf.edu.au:AAFProduction'
    end

  end

  describe "#save_sources" do
    it "should save the sources list to a file" do
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
      tmpfile.close
      Shibkit::MetaMeta.save_sources(sourcesfile)
      referencefile = File.open("#{File.dirname(__FILE__)}/saved_sources.yaml").read
      resultfile = File.open(sourcesfile).read
      Shibkit::MetaMeta.config.logger.debug "referencefile (MD5:#{Digest::MD5.hexdigest(referencefile)}):\n#{referencefile}\nsavedfile (MD5:#{Digest::MD5.hexdigest(resultfile)}):\n#{resultfile}\n"
      (File.exists? sourcesfile).should == true &&
      resultfile.should == referencefile
    end
  end
  describe "#load_sources" do
    it "should automatically load sources if no source file has been specified." do
      Shibkit::MetaMeta.load_sources
      Shibkit::MetaMeta.loaded_sources.size.should == 4 &&
      Shibkit::MetaMeta.loaded_sources?.should == true &&
      Shibkit::MetaMeta.loaded_sources.keys[2].should == 'http://ukfederation.org.uk'
    end
    it "should be possible to set the file to load from" do
      Shibkit::MetaMeta.config.sources_file="#{File.dirname(__FILE__)}/saved_sources.yaml"
    end
    it "should load sources from a file" do
      Shibkit::MetaMeta.config.sources_file="#{File.dirname(__FILE__)}/saved_sources.yaml"
      Shibkit::MetaMeta.load_sources
      Shibkit::MetaMeta.loaded_sources.size.should == 2 &&
      Shibkit::MetaMeta.loaded_sources?.should == true &&
      Shibkit::MetaMeta.loaded_sources.keys[1].should == 'http://ukfederation.org.uk' &&
      Shibkit::MetaMeta.loaded_sources.keys[0].should == 'urn:mace:aaf.edu.au:AAFProduction'
    end
  end

  
  describe "#process_sources" do
    it "should read it's sources and return an array of federation objects" do
      federations = Shibkit::MetaMeta.process_sources
      federations.size.should > 0
    end
  end
  describe "#save_cache_file" do
    it "should save the federation cache to a file" do
      federations = Shibkit::MetaMeta.process_sources
      tmpfile = Tempfile.new('metametacache')
      cachefile = tmpfile.path
      Shibkit::MetaMeta.save_cache_file(cachefile)
      (File.exists? cachefile).should == true
    end
  end
  describe "#load_cache_file" do
    it "should load objects from a cache file" do
      Shibkit::MetaMeta.load_cache_file("#{File.dirname(__FILE__)}/cache_example.yaml")
      Shibkit::MetaMeta.stocked?.should == true
    end 
  end
  describe "#flush" do
    it "should clear the cache" do
      Shibkit::MetaMeta.load_cache_file("#{File.dirname(__FILE__)}/cache_example.yaml")
      Shibkit::MetaMeta.stocked?.should == true &&
      Shibkit::MetaMeta.flush &&
      Shibkit::MetaMeta.stocked?.should == false
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
    it "should refresh selected federations"
    it "should not referesh federations that are not selected"
    it "shouldn't refresh, (under certain conditions)"
    it "should be forcable"
  end
  describe "#stockup" do
    it "should load sources, if it is configured to auto-load"
    it "shouldn't do anything if it isn't configured to auto-load"
    it "shouldn't load sources if they have already been loaded"
  end
  describe "#federations" do
    it "should auto-initilize"
    it "should return a array of Shibkit::Federation objects"
  end
  describe "#entities" do
    it "should return an array of Shibkit::Entitie objects"
  end
  describe "#orgs" do
    it "should return an array of Shibkit::Organisation objects, sorted by druid"
  end
  describe "#idps" do
    it "should return an array of Shibkit::Idp objects"
  end
  describe "#sps" do
    it "should return an array of Shibkit::Sp objects"
  end
  describe "#from_uri" do
    # TODO I don't know what this is for
  end

end
