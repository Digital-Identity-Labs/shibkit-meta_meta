require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "tag settings behaviour" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do                                                            
    @config_class = Shibkit::MetaMeta::Config.clone                                                             
    @config       = @config_class.instance                               
  end
  
  subject { @config }
  
  it { is_expected.to respond_to :auto_tag= }
  it { is_expected.to respond_to :auto_tag?  }
  it { is_expected.to respond_to :merge_primary_tags= }
  it { is_expected.to respond_to :merge_primary_tags? }

  it "should allow autotagging to be enabled and disabled" do
    
    @config.auto_tag = false
    expect(@config.auto_tag?).to eq(false)
    
    @config.auto_tag = true
    expect(@config.auto_tag?).to eq(true)
    
  end
  
  it "should return current autotagging setting, as a boolean" do
  
    @config.auto_tag = false
    expect(@config.auto_tag?).to eq(false)
    
    @config.auto_tag = true
    expect(@config.auto_tag?).to eq(true)
    
    @config.auto_tag = nil 
    expect(@config.auto_tag?).to eq(false) 
  
  end
   
  it "should allow merging of primary tags to be enabled and disabled" do
    
    @config.merge_primary_tags = false
    expect(@config.merge_primary_tags?).to eq(false)
    
    @config.merge_primary_tags = true
    expect(@config.merge_primary_tags?).to eq(true)
    
    
  end
  
  it "should return current setting for merging of primary tags, as a boolean" do
    
    @config.merge_primary_tags = false
    expect(@config.merge_primary_tags?).to eq(false)
    
    @config.merge_primary_tags = true
    expect(@config.merge_primary_tags?).to eq(true)
    
    @config.merge_primary_tags = nil 
    expect(@config.merge_primary_tags?).to eq(false)
    
  end
  
  context "by default" do
    
    it "should have autotagging disabled by default" do
      
      expect(@config.auto_tag?).to eq(false)
      
    end
    
    it "should have merging of primary tags enabled by default" do
      
      expect(@config.merge_primary_tags?).to eq(true)
      
    end
    
  end

end