require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "automatic download and refresh settings" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do
    @config_class = Shibkit::MetaMeta::Config.clone                                                             
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { is_expected.to respond_to :autoload=  }
  it { is_expected.to respond_to :autoload? }
  it { is_expected.to respond_to :auto_refresh= }
  it { is_expected.to respond_to :auto_refresh? }
  
  context "When using default settings" do
    
    it "should have autoload set to be active" do
      
      expect(@config.autoload?).to eq(true)
      
    end
    
    it "should have auto_refresh set to active" do
      
      expect(@config.auto_refresh?).to eq(true)
      
    end
    
  end
  
  context "When changing settings" do
    
    it "should allow autoload setting to be enable or disabled" do
      
      @config.autoload=true
      expect(@config.autoload?).to eq(true)
      @config.autoload=false
      expect(@config.autoload?).to eq(false)
    
    end
    
    it "should allow auto_refresh setting to be enabled or disabled" do
      
      @config.auto_refresh=true
      expect(@config.auto_refresh?).to eq(true)
      @config.auto_refresh=false
      expect(@config.auto_refresh?).to eq(false)
      
    end
    
    it "should only return true or false for #autoload?" do
      
      @config.autoload="yup" # Potentially misleading
      expect(@config.autoload?).to eq(true)
      @config.autoload=nil
      expect(@config.autoload?).to eq(false)
      
    end
    
    it "should only return true or false for #auto_refresh?" do
      @config.auto_refresh="yup" # Potentially misleading
      expect(@config.auto_refresh?).to eq(true)
      @config.auto_refresh=nil
      expect(@config.auto_refresh?).to eq(false)
    end
    
  end
  
end