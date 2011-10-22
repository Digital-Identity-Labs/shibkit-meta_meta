require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "logging settings" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do
    @config_class = Shibkit::MetaMeta::Config.clone                                                             
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { should respond_to :logger=  }
  it { should respond_to :logger }
  it { should respond_to :verbose_downloads= }
  it { should respond_to :verbose_downloads? }
  it { should respond_to :downloads_logger= }
  it { should respond_to :downloads_logger }

  it "should allow any standard Ruby logger to be set as #logger" do
    
    log_to_stdout = Logger.new(STDOUT)
    expect { @config.logger = log_to_stdout }.should_not raise_error
    
  end
  
  it "should allow normal logger options to be set on logger" do
    
    expect { @config.logger.level = ::Logger::DEBUG }.should_not raise_error
    
  end
  
  it "should allow a standard Ruby logger to be set as the download logger" do
    
    mrlog = Logger.new(STDOUT)
    expect { @config.downloads_logger = mrlog }.should_not raise_error
    
  end
  
  it "should allow normal logging options to be set on the download logger" do
    
    expect { @config.logger.level = ::Logger::DEBUG }.should_not raise_error
        
  end
  
  it "should allow the downloads logger to be set to the main logger" do
    
    expect { @config.downloads_logger = @config.logger }.should_not raise_error
    expect { @config.downloads_logger.info "Boo" }
    
  end
  
  context "by default" do
    
    it "should have verbose downloads turned off" do
      
      @config.verbose_downloads?.should be_false
      
    end
    
    it "should not have a download logger specified" do
    
      @config.downloads_logger.should be_nil  
      
    end
    
    it "should have a default logger" do
      
      @config.logger.should be_kind_of Logger
      
    end
    
  end

  describe "The default logger" do
    
    it "should output to STDOUT"
    
    it "should be set to INFO output level" do
      
      @config.logger.level.should == Logger::INFO
      
    end
    
    it "should name the application as MetaMeta"
    it "should include severity/loglevel in output"
    it "should include data/time in output"
    
  end

end