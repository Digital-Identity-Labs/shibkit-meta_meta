require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "download and file caching settings" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do
    @config_class = Shibkit::MetaMeta::Config.clone                                                             
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { should respond_to :download_cache_options=  }
  it { should respond_to :download_cache_options }
  it { should respond_to :verbose_downloads= }
  it { should respond_to :verbose_downloads }
  it { should respond_to :cache_fallback_ttl= }
  it { should respond_to :cache_fallback_ttl }
  
  it "should return a hash of cache options" do
    
  end
  
  it "cache options should be compatible with Rack::Cache" do
    
  end
  
  it "should represent download cache data and metadata locations as URLs" do
    
  end
  
  context "When using default settings" do
    
    describe "the cache options hash" do
    
      it "should have a two hour default TTL for cached files" do
        
      end
      
      it "should store cached metadata inside the cache root in a folder called metadata" do
      
      end
      
      it "should store cached data inside the cache root in a folder called data" do
      
      end
      
      it "should have verbose output set to false" do
        
      end
      
    end
    
    it "should have a fallback ttl of two hours" do
      
    end
    
    it "should have the verbose download setting return false" do
      
    end
    
  end
  
  context "When changing settings" do
    
    it "should change the configuration hash when verbose downloads setting is changed" do
      
      
    end
    
    it "should change the configuration hash when cache root is changed" do
      
      
      
    end
    
    it "should change the configuration hash when default ttl is changed" do
      
      
    end
    
    it "should allow direct manipulation of the config hash" do
      
      
      
    end
    
    it "should allow other, more obscure Rack::Cache options to be set directly" do
      
      
    end
    
  end
  
end


