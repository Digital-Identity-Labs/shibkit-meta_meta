require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "creation and singleton behaviour" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do                                                            
    @config_class = Shibkit::MetaMeta::Config.clone                                
  end
  
  subject { @config_class }
  
  it { is_expected.to respond_to :instance }
  
  
  it "Should raise an exception if #new is called" do
    
    expect {  @config_class.new }.to raise_error
    
  end
  
  context "When first instance is created" do
    
    it "should return a Config object" do
      
      expect(Shibkit::MetaMeta::Config.instance.class).to eq(Shibkit::MetaMeta::Config)
      
    end
    
  end
  
  context "When an instance is created again" do
  
    it "should also be the same object, effectively a singleton" do
      
      first  = @config_class.instance
      second = @config_class.instance
      expect(first).to eq(second)
      
    end
  
  end
  
end