require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "working directory/cache directory behaviour" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do                                                            
    @config_class = Shibkit::MetaMeta::Config.clone                                                             
    @config       = @config_class.instance                               
  end
  
  subject { @config }
  
  it { is_expected.to respond_to :cache_root= }
  it { is_expected.to respond_to :cache_root  }
  it { is_expected.to respond_to :can_delete= }
  it { is_expected.to respond_to :can_delete? }

  it "should return the location of the cache_root directory as a string" do
    
    expect(@config.cache_root).to be_kind_of String
    
  end
  
  it "should allow the cache root directory to be set" do
    
    @config.cache_root = "/tmp/bananas"
    expect(@config.cache_root).to eq("/tmp/bananas")
    
  end
  
  it "should allow can_delete setting to be changed" do
    
    @config.can_delete = true
    expect(@config.can_delete?).to eq(true)
    
    @config.can_delete = false
    expect(@config.can_delete?).to eq(false)
    
  end
  
  it "should have can_delete? returning boolean values" do
    
    @config.can_delete = true
    expect(@config.can_delete?).to eq(true)
    
    @config.can_delete = false
    expect(@config.can_delete?).to eq(false)
   
    @config.can_delete = nil
    expect(@config.can_delete?).to eq(false)
    
    @config.can_delete = "I suppose so" # dangerous, I suppose.
    expect(@config.can_delete?).to eq(true)
    
  end
  
  context "by default" do
    
    it "should have #can_delete? return false. Just in case." do
      
      expect(@config.can_delete?).to eq(false)
      
    end
    
    context "on Windows" do

      xit "should store cache files under the default TEMP directory" do

        allow_any_instance_of(@config_class).to receive(:sensible_os?).and_return(false)
        tempbase = 'c:\Temp'
        ENV['TEMP'] = tempbase

        expect(@config.cache_root).to include tempbase.gsub('\\','/')

        # Failing because on Linux File.join does the right thing - need
        # to temporarily force it to behave like window just for this test...

      end

    end

    context "on sensible operating systems" do

      it "should store cache files in /tmp/" do

        allow_any_instance_of(@config_class).to receive(:sensible_os?).and_return(true)
        tempbase = '/tmp'

        expect(@config.cache_root).to include tempbase

      end
      
    end
    
    it "should store cache files in a directory called skmm-cache" do

      allow_any_instance_of(@config_class).to receive(:sensible_os?).and_return(true)
      tempbase = '/tmp'

      expect(@config.cache_root).to match /skmm-cache$/

    end
    
  end
  
end