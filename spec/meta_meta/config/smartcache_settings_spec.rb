require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "Smartcache settings behavior" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do                                                            
    @config_class = Shibkit::MetaMeta::Config.clone
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { should respond_to :smartcache_expiry= }
  it { should respond_to :smartcache_expiry }
  it { should respond_to :smartcache_active= }
  it { should respond_to :smartcache_active? }
  it { should respond_to :smartcache_object_file }
  it { should respond_to :smartcache_info_file }
 
  it "should allow the #smartcache_expiry time to be set in seconds, with integer or string" do
    
    @config.smartcache_expiry = 600
    @config.smartcache_expiry.should == 600
    @config.smartcache_expiry = "700"
    @config.smartcache_expiry.should == 700
    @config.smartcache_expiry = "800s"
    @config.smartcache_expiry.should == 800    
        
  end
  
  it "should return the #smartcache_expiry time to be returned as an integer" do
    
    @config.smartcache_expiry = 400
    @config.smartcache_expiry.should be_a_kind_of Fixnum
    
  end
  
  it "should allow the smartcache to be enabled or disabled" do
    
    @config.smartcache_active = true
    @config.smartcache_active?.should be_true
    
    @config.smartcache_active = false
    @config.smartcache_active?.should be_false
    
    @config.smartcache_active = nil
    @config.smartcache_active?.should be_false
    
  end
  
  it "should return if the smartcache is enabled or disabled" do
    @config.smartcache_active = true
    @config.smartcache_active?.should be_true
    
    @config.smartcache_active = false
    @config.smartcache_active?.should be_false
    
  end
  
  it "should return the location of the smartcache object data" do
    
    @config.smartcache_object_file.should be_kind_of String
    @config.smartcache_object_file.should match /\/smartcache.marshal$/
    
  end
  
  it "should return the location of the smartcache metadata" do
    
    @config.smartcache_info_file.should be_kind_of String
    @config.smartcache_info_file.should match /\/smartcache.yml$/
    
  end
  
  it "should save smartcache files in the cache_root, even if it changes" do
    
    @config.smartcache_object_file.should include @config.cache_root
    @config.smartcache_object_file.should include @config.cache_root

    @config.cache_root = "/tmp/another_root"
    
    @config.smartcache_object_file.should include @config.cache_root
    @config.smartcache_object_file.should include @config.cache_root
    

  end
  
  context "by default" do
    
    it "should have smartcache enabled" do
      
      @config.smartcache_active?.should == true
      
    end
    
    it "should have smartcache set to expire in two hours" do
      
      @config.smartcache_expiry.should == 3600
      
    end
    
    it "should save smartcache files in the default cache_root" do

      @config.smartcache_object_file.should include @config.cache_root
      @config.smartcache_object_file.should include @config.cache_root

    end
    
  end
  
end
