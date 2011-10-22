require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "Source file location behaviour" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do                                                            
    @config_class = Shibkit::MetaMeta::Config.clone
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { should respond_to :sources_file= }
  it { should respond_to :sources_file  }
  
  it "should allow setting of source file location to any filesystem path" do
    
    @config.sources_file = "/tmp/sources.yml"
    @config.sources_file.should == "/tmp/sources.yml"
    
  end
  
  it "should allow setting of source file location to any HTTP or HTTPS URL" do
    
    @config.sources_file = "http://localhost/sources.yml"
    @config.sources_file.should == "http://localhost/sources.yml"
    
  end
 
  it "should return the actual file location" do
    
    @config.sources_file = "/tmp/test.yml"
    @config.sources_file.should == "/tmp/test.yml"
    
  end

  it "should allow source file to be set automatically from default data by passing :auto [TODO]" do 
    
    @config.sources_file = :auto
    @config.sources_file.should match /\/data\/(.+)_sources.yml$/
    
  end
  
  it "should automatically select source data suitable for dev environment if file isn't set [TODO]" do
    
    @config.environment = :development
    @config.sources_file.should match /\/data\/real_sources.yml$/ ## Temp - needs suitable file
    
  end
  
  it "should automatically select source data suitable for production environment if file isn't set" do
    
    @config.environment = :production 
    @config.sources_file.should match /\/data\/real_sources.yml$/ ## Temp - needs suitable file
    
  end
  
  it "should automatically select source data suitable for test environment if file isn't set [TODO]" do
    
    @config.environment = :test
    @config.sources_file.should match /\/data\/real_sources.yml$/ ## Temp - needs suitable file
    
  end
  
  it "should allow selection of default source file suitable for dev work [TODO]" do
    
    [:dev, :development].each do |sym|
      
      @config.sources_file = sym
      @config.sources_file.should match /\/data\/real_sources.yml$/ ## Temp - needs suitable file
      
    end
    
  end
  
  it "should allow selection of default source file suitable for testing work [TODO]" do
    
    [:test, :testing].each do |sym|
      
      @config.sources_file = sym
      @config.sources_file.should match /\/data\/real_sources.yml$/ ## Temp - needs suitable file
      
    end
    
  end

  it "should allow selection of default source file suitable for production work [TODO]" do
    
    [:real, :prod, :production, :all, :full].each do |sym|
      
      @config.sources_file = sym
      @config.sources_file.should match /\/data\/real_sources.yml$/ ## Temp - needs suitable file
      
    end
    
  end
  
end
 