require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "automatic download and refresh settings" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do
    @config_class = Shibkit::MetaMeta::Config.clone                                                             
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { should respond_to :autoload=  }
  it { should respond_to :autoload? }
  it { should respond_to :auto_refresh= }
  it { should respond_to :auto_refresh? }
  
  context "When using default settings" do
    
    it "should have autoload set to be active" do
      
      @config.autoload?.should == true
      
    end
    
    it "should have autorefresh set to active" do
      
      @config.auto_refresh?.should == true
      
    end
    
  end
  
  context "When changing settings" do
    
    it "should allow autoload setting to be enable or disabled" do
      
      @config.autoload=true
      @config.autoload?.should == true
      @config.autoload=false
      @config.autoload?.should == false
    
    end
    
    it "should allow autorefresh setting to be enabled or disabled" do
      
      @config.auto_refresh=true
      @config.auto_refresh?.should == true
      @config.auto_refresh=false
      @config.auto_refresh?.should == false
      
    end
    
    it "should only return true or false for #autoload?" do
      
      @config.autoload="yup" # Potentially misleading
      @config.autoload?.should == true
      @config.autoload=nil
      @config.autoload?.should == false
      
    end
    
    it "should only return true or false for #auto_refresh?" do
      @config.auto_refresh="yup" # Potentially misleading
      @config.auto_refresh?.should == true
      @config.auto_refresh=nil
      @config.auto_refresh?.should == false
    end
    
  end
  
end