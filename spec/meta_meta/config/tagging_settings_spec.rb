require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "tag settings behaviour" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do                                                            
    @config_class = Shibkit::MetaMeta::Config.clone                                                             
    @config       = @config_class.instance                               
  end
  
  subject { @config }
  
  it { should respond_to :auto_tag= }
  it { should respond_to :auto_tag?  }
  it { should respond_to :merge_primary_tags= }
  it { should respond_to :merge_primary_tags? }

  it "should allow autotagging to be enabled and disabled" do
    
    @config.auto_tag = false
    @config.auto_tag?.should == false
    
    @config.auto_tag = true
    @config.auto_tag?.should == true
    
  end
  
  it "should return current autotagging setting, as a boolean" do
  
    @config.auto_tag = false
    @config.auto_tag?.should == false
    
    @config.auto_tag = true
    @config.auto_tag?.should == true
    
    @config.auto_tag = nil 
    @config.auto_tag?.should == false 
  
  end
   
  it "should allow merging of primary tags to be enabled and disabled" do
    
    @config.merge_primary_tags = false
    @config.merge_primary_tags?.should == false
    
    @config.merge_primary_tags = true
    @config.merge_primary_tags?.should == true
    
    
  end
  
  it "should return current setting for merging of primary tags, as a boolean" do
    
    @config.merge_primary_tags = false
    @config.merge_primary_tags?.should == false
    
    @config.merge_primary_tags = true
    @config.merge_primary_tags?.should == true
    
    @config.merge_primary_tags = nil 
    @config.merge_primary_tags?.should == false
    
  end
  
  context "by default" do
    
    it "should have autotagging disabled by default" do
      
      @config.auto_tag?.should == false
      
    end
    
    it "should have merging of primary tags enabled by default" do
      
      @config.merge_primary_tags?.should == true
      
    end
    
  end

end