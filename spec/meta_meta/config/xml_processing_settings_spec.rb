require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "XML processing settings behaviour" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do                                                            
    @config_class = Shibkit::MetaMeta::Config.clone
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { is_expected.to respond_to :purge_xml= }
  it { is_expected.to respond_to :purge_xml? }
  it { is_expected.to respond_to :remember_source_xml= }
  it { is_expected.to respond_to :remember_source_xml? }
  
  context "By default" do
    
    it "should have #purge_xml set to true" do 
      
      expect(@config.purge_xml?).to be_truthy
      
    end
    
    it "should have #remember_source_xml set to false" do
      
      expect(@config.remember_source_xml?).to be_falsey
      
    end
    
  end
  
  
  it "should return if the #purge_xml? setting is active or not, only as a boolean" do
    
    @config.purge_xml = false
    expect(@config.purge_xml?).to be_falsey
    @config.purge_xml = nil
    expect(@config.purge_xml?).to be_falsey
    @config.purge_xml = true
    expect(@config.purge_xml?).to be_truthy
    
  end

  it "should return if the #remember_source_xml? setting is active or not, only as a boolean" do
    
    @config.remember_source_xml = false
    expect(@config.remember_source_xml?).to be_falsey
    @config.remember_source_xml = nil
    expect(@config.remember_source_xml?).to be_falsey
    @config.remember_source_xml = true
    expect(@config.remember_source_xml?).to be_truthy
    
  end

  it "should allow #purge_xml setting to be activated and deactivated" do
    
    @config.purge_xml = false
    expect(@config.purge_xml?).to be_falsey    
    @config.purge_xml = true
    expect(@config.purge_xml?).to be_truthy
    
  end
  
  it "should allow #remember_source_xml setting to be activated and deactivated" do
    
    @config.remember_source_xml = false
    expect(@config.remember_source_xml?).to be_falsey
    @config.remember_source_xml = true
    expect(@config.remember_source_xml?).to be_truthy
    
  end

end
