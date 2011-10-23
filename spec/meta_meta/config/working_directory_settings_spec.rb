require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "working directory/cache directory behaviour" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do                                                            
    @config_class = Shibkit::MetaMeta::Config.clone                                                             
    @config       = @config_class.instance                               
  end
  
  subject { @config }
  
  it { should respond_to :cache_root= }
  it { should respond_to :cache_root  }
  it { should respond_to :can_delete= }
  it { should respond_to :can_delete? }

  it "should return the location of the cache_root directory as a string" do
    
    @config.cache_root.should be_kind_of String
    
  end
  
  it "should allow the cache root directory to be set" do
    
    @config.cache_root = "/tmp/bananas"
    @config.cache_root.should == "/tmp/bananas"
    
  end
  
  it "should allow can_delete setting to be changed" do
    
    @config.can_delete = true
    @config.can_delete?.should == true
    
    @config.can_delete = false
    @config.can_delete?.should == false
    
  end
  
  it "should have can_delete? returning boolean values" do
    
    @config.can_delete = true
    @config.can_delete?.should == true
    
    @config.can_delete = false
    @config.can_delete?.should == false
   
    @config.can_delete = nil
    @config.can_delete?.should == false
    
    @config.can_delete = "I suppose so" # dangerous, I suppose.
    @config.can_delete?.should == true
    
  end
  
  context "by default" do
    
    it "should have #can_delete? return false. Just in case." do
      
      @config.can_delete?.should == false
      
    end
    
    context "on Windows" do

      it "should store cache files under the default TEMP directory" do

        @config_class.any_instance.stub(:sensible_os?).and_return(false)
        tempbase = 'c:\Temp'
        ENV['TEMP'] = tempbase

        @config.cache_root.should include tempbase.gsub('\\','/')

        # Failing because on Linux File.join does the right thing - need
        # to temporarily force it to behave like window just for this test...

      end

    end

    context "on sensible operating systems" do

      it "should store cache files in /tmp/" do

        @config_class.any_instance.stub(:sensible_os?).and_return(true)
        tempbase = '/tmp'

        @config.cache_root.should include tempbase

      end
      
    end
    
    it "should store cache files in a directory called skmm-cache" do

      @config_class.any_instance.stub(:sensible_os?).and_return(true)
      tempbase = '/tmp'

      @config.cache_root.should match /skmm-cache$/

    end
    
  end
  
end