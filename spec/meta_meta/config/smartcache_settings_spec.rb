require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "Smartcache settings behavior" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do                                                            
    @config_class = Shibkit::MetaMeta::Config.clone
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { is_expected.to respond_to :smartcache_expiry= }
  it { is_expected.to respond_to :smartcache_expiry }
  it { is_expected.to respond_to :smartcache_active= }
  it { is_expected.to respond_to :smartcache_active? }
  it { is_expected.to respond_to :smartcache_object_file }
  it { is_expected.to respond_to :smartcache_info_file }
 
  it "should allow the #smartcache_expiry time to be set in seconds, with integer or string" do
    
    @config.smartcache_expiry = 600
    expect(@config.smartcache_expiry).to eq(600)
    @config.smartcache_expiry = "700"
    expect(@config.smartcache_expiry).to eq(700)
    @config.smartcache_expiry = "800s"
    expect(@config.smartcache_expiry).to eq(800)    
        
  end
  
  it "should return the #smartcache_expiry time to be returned as an integer" do
    
    @config.smartcache_expiry = 400
    expect(@config.smartcache_expiry).to be_a_kind_of Fixnum
    
  end
  
  it "should allow the smartcache to be enabled or disabled" do
    
    @config.smartcache_active = true
    expect(@config.smartcache_active?).to be_truthy
    
    @config.smartcache_active = false
    expect(@config.smartcache_active?).to be_falsey
    
    @config.smartcache_active = nil
    expect(@config.smartcache_active?).to be_falsey
    
  end
  
  it "should return if the smartcache is enabled or disabled" do
    @config.smartcache_active = true
    expect(@config.smartcache_active?).to be_truthy
    
    @config.smartcache_active = false
    expect(@config.smartcache_active?).to be_falsey
    
  end
  
  it "should return the location of the smartcache object data" do
    
    expect(@config.smartcache_object_file).to be_kind_of String
    expect(@config.smartcache_object_file).to match /\/smartcache.marshal$/
    
  end
  
  it "should return the location of the smartcache metadata" do
    
    expect(@config.smartcache_info_file).to be_kind_of String
    expect(@config.smartcache_info_file).to match /\/smartcache.yml$/
    
  end
  
  it "should save smartcache files in the cache_root, even if it changes" do
    
    expect(@config.smartcache_object_file).to include @config.cache_root
    expect(@config.smartcache_object_file).to include @config.cache_root

    @config.cache_root = "/tmp/another_root"
    
    expect(@config.smartcache_object_file).to include @config.cache_root
    expect(@config.smartcache_object_file).to include @config.cache_root
    

  end
  
  context "by default" do
    
    it "should have smartcache enabled" do
      
      expect(@config.smartcache_active?).to eq(true)
      
    end
    
    it "should have smartcache set to expire in two hours" do
      
      expect(@config.smartcache_expiry).to eq(3600)
      
    end
    
    it "should save smartcache files in the default cache_root" do

      expect(@config.smartcache_object_file).to include @config.cache_root
      expect(@config.smartcache_object_file).to include @config.cache_root

    end
    
  end
  
end
