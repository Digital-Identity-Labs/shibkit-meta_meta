require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "configuration blocks" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do                                                            
    @config_class = Shibkit::MetaMeta::Config.clone
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { should respond_to :configure }
  
  it "Should allow a configuration block to be used at object creation" do
    
    my_config = @config_class.instance { |c| c.smartcache_expiry = 12345 }
    my_config.smartcache_expiry.should == 12345
        
  end
  
  it "Should allow a configuration block to be used at any time" do
    
    my_config = @config_class.instance
    my_config.configure { |c| c.smartcache_expiry = 3333 }
    my_config.smartcache_expiry.should == 3333
    
  end
    
end