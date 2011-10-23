require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "source and federation filtering settings" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do
    @config_class = Shibkit::MetaMeta::Config.clone                                                             
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { should respond_to :only_use  }
  it { should respond_to :selected_federation_uris= }
  it { should respond_to :selected_federation_uris  }
  it { should respond_to :selected_groups= }
  it { should respond_to :selected_groups }

  it "should allow #only_use as a alternative to #selected_federation_uris" do
    
    @config.only_use("http://ukfederation.org.uk")
    @config.selected_federation_uris.should == ["http://ukfederation.org.uk"]
    
    uris_list = ["http://ukfederation.org.uk",'urn:mace:incommon']
    @config.only_use(uris_list)
    @config.selected_federation_uris.should =~ ["http://ukfederation.org.uk",'urn:mace:incommon']
    
  end
  
  it "selected federations URIs should always be returned as a list" do
    
    @config.selected_federation_uris = "http://ukfederation.org.uk"
    @config.selected_federation_uris.should be_kind_of Array
    
    uris_list = ["http://ukfederation.org.uk",'urn:mace:incommon']
    @config.selected_federation_uris = uris_list
    @config.selected_federation_uris.should be_kind_of Array
    
  end
  
  it "should allow selection of a single federation/source URI string to load" do
    
    @config.selected_federation_uris = "http://ukfederation.org.uk"
    @config.selected_federation_uris.should == ["http://ukfederation.org.uk"]
    
  end
  
  it "should allow selection of a list of federations/sources (as URIs) to load" do
    
    uris_list = ["http://ukfederation.org.uk",'urn:mace:incommon']
    @config.selected_federation_uris = uris_list
    @config.selected_federation_uris.should =~ ["http://ukfederation.org.uk",'urn:mace:incommon']
  
  end
  
  it "should allow selected of a list of federations/sources from a Hash" do
    
    uris_hash = {
      'http://ukfederation.org.uk' => "potato",
      'urn:mace:incommon' => 'potato'
    }
      
    @config.selected_federation_uris = uris_hash
    @config.selected_federation_uris.should =~ ["http://ukfederation.org.uk",'urn:mace:incommon']
    
  end
  
  it "should allow (re)selection of all sources/federations using :all or :everything symbols" do
    
    @config.selected_federation_uris = :all
    @config.selected_federation_uris.should == []
    
    @config.selected_federation_uris = :everything
    @config.selected_federation_uris.should == []
    
  end

  it "should allow selection of all sources/federations by passing a nil or false to indicate no preference" do
    
    @config.selected_federation_uris = nil
    @config.selected_federation_uris.should == []
    
    @config.selected_federation_uris = false
    @config.selected_federation_uris.should == []
    
  end
  
  it "should allow selection of all sources/federations by passing an empty array or hash" do
    
    @config.selected_federation_uris = []
    @config.selected_federation_uris.should == []
    
    @config.selected_federation_uris = {}
    @config.selected_federation_uris.should == []
    
  end
  
  it "should allow selection of source one source group by name" do
    
    @config.selected_groups = "spec_set_1"
    @config.selected_groups.should =~ ['spec_set_1']
    
  end
  
  it "should allow selection of a list of source groups by an array of names" do
    
    @config.selected_groups = ["spec_set_1", "spec_set_2"]
    @config.selected_groups.should =~ ["spec_set_1", "spec_set_2"]
    
  end

  it "selected source groups should always be returned as an array" do
    
    @config.selected_groups = ["spec_set_1", "spec_set_2"]
    @config.selected_groups.should be_kind_of Array
    
    @config.selected_groups = "spec_set_1"
    @config.selected_groups.should be_kind_of Array
        
  end
  

end