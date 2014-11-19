require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "platform settings" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do
    @config_class = Shibkit::MetaMeta::Config.clone                                                             
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { is_expected.to respond_to :environment=  }
  it { is_expected.to respond_to :environment }
  it { is_expected.to respond_to :in_production? }
  it { is_expected.to respond_to :version }
  it { is_expected.to respond_to :platform }
  
  it "should allow the #environment to be set" do
    
    @config.environment = :porcupine
    expect(@config.environment).to eq(:porcupine)
    
  end
  
  it "should return an environment as a symbol when set" do
    
    @config.environment = "testing"
    expect(@config.environment).to eq(:testing)
    
  end
  
  it "should return :development from #environment by default" do
    
    expect(@config.environment).to eq(:development)
    
  end
  
  context "if #environment has been set and #in_production is called" do
    
    it "should return true if #environment is :production" do
      
      @config.environment = :production
      expect(@config.in_production?).to be_truthy
      
    end
    
    it "should return false if #environment is :development" do
      
      @config.environment = :development
      expect(@config.in_production?).to be_falsey
      
    end
    
    it "should return false if #environment is :test" do
      
      @config.environment = :test
      expect(@config.in_production?).to be_falsey
      
    end
    
  end
  
  context "If #environment has not been set and #in_production? has been called" do
    
    it "should return true if Rails environment set and is production" do
       
      Rails = Class.new unless defined? Rails # Smells...
      allow(Rails).to receive_message_chain(:env,:production?).and_return(true)

      expect(@config.in_production?).to be_truthy
      
    end
    
    it "should return false if Rails environment set and is not :production" do
      
      Rails = Class.new unless defined? Rails # Smells...
      
      allow(Rails).to receive_message_chain(:env,:production?).and_return(false)      
      expect(@config.in_production?).to be_falsey
      
    end
    
    it "should return true if Rack environment set and is 'production'" do
      
      Rack = Class.new unless defined? Rack # Smells...
      RACK_ENV = 'production'
      
      expect(@config.in_production?).to be_truthy
      
    end
    
    it "should return false if Rack environment set is not :production" do
      
      Rack = Class.new unless defined Rack # Smells...
      RACK_ENV = 'development'
      
      expect(@config.in_production?).to be_falsey
      
    end
    
    it "should return false if environment, Rack and Rails are all undefined" do
      
      expect(@config.in_production?).to be_falsey
    
    end
    
  end
  
  it "should return a version string from #version with at least three parts" do
    
    expect(@config.version).to be_a_kind_of String
    expect(@config.version.split('.').count).to be > 2
        
  end
  
  it "should return a version string matching the MAJOR.MINOR.PATCH pattern" do
    
    expect(@config.version).to match /^(\d+)\.(\d+)\.(\d+)/
        
  end
  
  it "should return a string for #platform made up of three parts" do
    
    expect(@config.platform.split(':').count).to eq(3)
    
  end
    
end