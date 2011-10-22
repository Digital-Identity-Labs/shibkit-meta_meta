require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "XML processing settings behaviour" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do                                                            
    @config_class = Shibkit::MetaMeta::Config.clone
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { should respond_to :purge_xml= }
  it { should respond_to :purge_xml? }
  it { should respond_to :remember_source_xml= }
  it { should respond_to :remember_source_xml? }
  
  context "By default" do
    
    it "should have #purge_xml set to true" do 
      
      @config.purge_xml?.should be_true
      
    end
    
    it "should have #remember_source_xml set to false" do
      
      @config.remember_source_xml?.should be_false
      
    end
    
  end
  
  
  it "should return if the #purge_xml? setting is active or not, only as a boolean" do
    
    @config.purge_xml = false
    @config.purge_xml?.should be_false
    @config.purge_xml = nil
    @config.purge_xml?.should be_false
    @config.purge_xml = true
    @config.purge_xml?.should be_true
    
  end

  it "should return if the #remember_source_xml? setting is active or not, only as a boolean" do
    
    @config.remember_source_xml = false
    @config.remember_source_xml?.should be_false
    @config.remember_source_xml = nil
    @config.remember_source_xml?.should be_false
    @config.remember_source_xml = true
    @config.remember_source_xml?.should be_true
    
  end

  it "should allow #purge_xml setting to be activated and deactivated" do
    
    @config.purge_xml = false
    @config.purge_xml?.should be_false    
    @config.purge_xml = true
    @config.purge_xml?.should be_true
    
  end
  
  it "should allow #remember_source_xml setting to be activated and deactivated" do
    
    @config.remember_source_xml = false
    @config.remember_source_xml?.should be_false
    @config.remember_source_xml = true
    @config.remember_source_xml?.should be_true
    
  end

end
