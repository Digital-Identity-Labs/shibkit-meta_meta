require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "platform settings" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do
    @config_class = Shibkit::MetaMeta::Config.clone                                                             
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { should respond_to :environment=  }
  it { should respond_to :environment }
  it { should respond_to :in_production? }
  it { should respond_to :version }
  it { should respond_to :platform }
  
  it "should allow the #environment to be set" do
    
    @config.environment = :porcupine
    @config.environment.should == :porcupine
    
  end
  
  it "should return an environment as a symbol when set" do
    
    @config.environment = "testing"
    @config.environment.should == :testing
    
  end
  
  it "should return :development from #environment by default" do
    
    @config.environment.should == :development
    
  end
  
  context "if #environment has been set and #in_production is called" do
    
    it "should return true if #environment is :production" do
      
      @config.environment = :production
      @config.in_production?.should be_true
      
    end
    
    it "should return false if #environment is :development" do
      
      @config.environment = :development
      @config.in_production?.should be_false
      
    end
    
    it "should return false if #environment is :test" do
      
      @config.environment = :test
      @config.in_production?.should be_false
      
    end
    
  end
  
  context "If #environment has not been set and #in_production? has been called" do
    
    it "should return true if Rails environment set and is production" do
       
      Rails = Class.new unless defined? Rails # Smells...
      Rails.stub_chain(:env,:production?).and_return(true)

      @config.in_production?.should be_true
      
    end
    
    it "should return false if Rails environment set and is not :production" do
      
      Rails = Class.new unless defined? Rails # Smells...
      
      Rails.stub_chain(:env,:production?).and_return(false)      
      @config.in_production?.should be_false
      
    end
    
    it "should return true if Rack environment set and is 'production'" do
      
      Rack = Class.new unless defined? Rack # Smells...
      RACK_ENV = 'production'
      
      @config.in_production?.should be_true
      
    end
    
    it "should return false if Rack environment set is not :production" do
      
      Rack = Class.new unless defined Rack # Smells...
      RACK_ENV = 'development'
      
      @config.in_production?.should be_false
      
    end
    
    it "should return false if environment, Rack and Rails are all undefined" do
      
      @config.in_production?.should be_false
    
    end
    
  end
  
  it "should return a version string from #version with at least three parts" do
    
    @config.version.should be_a_kind_of String
    @config.version.split('.').count.should be > 2
        
  end
  
  it "should return a version string matching the MAJOR.MINOR.PATCH pattern" do
    
    @config.version.should match /^(\d+)\.(\d+)\.(\d+)/
        
  end
  
  it "should return a string for #platform made up of three parts" do
    
    @config.platform.split(':').count.should == 3
    
  end
    
end