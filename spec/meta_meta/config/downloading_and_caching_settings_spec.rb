require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')
require 'rack/cache'

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
  it { should respond_to :verbose_downloads? }
  it { should respond_to :cache_fallback_ttl= }
  it { should respond_to :cache_fallback_ttl }
  
  it "should return a hash of cache options" do
    
    @config.download_cache_options.should be_a_kind_of Hash
    
  end
  
  it "cache options should be compatible with Rack::Cache" do
    
    options = @config.download_cache_options
    expect {RestClient.enable Rack::Cache, options}.should_not raise_error
    
  end
  
  it "should represent download cache data and metadata locations as URLs" do
    options = @config.download_cache_options
    options[:metastore].should   match URL_REGEX
    options[:entitystore].should match URL_REGEX
  end
  
  context "When using default settings" do
    
    describe "the cache options hash" do

      before(:each) do                                                         
        @cache_options = @config.download_cache_options                                
      end
      
      it "should have a two hour default TTL for cached files" do
        @cache_options[:default_ttl].should == 7200
      end
      
      it "should store cached metadata inside the cache root in a folder called meta" do
        location =  @cache_options[:metastore]
        location.should include @config.cache_root
        location.should include 'meta'
      end
      
      it "should store cached data inside the cache root in a folder called body" do
        location =  @cache_options[:entitystore]
        location.should include @config.cache_root
        location.should include 'body'
      end
      
      it "should have verbose output set to false" do
        @cache_options[:verbose].should be_false
      end
      
    end
    
    it "should have a fallback ttl of two hours" do
      @config.cache_fallback_ttl.should == 7200
    end
    
    it "should have the verbose download setting return false" do
      @config.verbose_downloads?.should be_false
    end
    
  end
  
  context "When changing settings" do
    
    it "should change the configuration hash when verbose downloads setting is changed" do
      
      @config.verbose_downloads?.should be_false
      @config.download_cache_options[:verbose].should be_false
           
      @config.verbose_downloads = true
      @config.download_cache_options[:verbose].should be_true
      
    end
    
    it "should change the configuration hash when cache root is changed" do
        
      @config.cache_root = "/tmp/work"
      @config.download_cache_options[:entitystore].should include "/tmp/work" 
      @config.download_cache_options[:metastore].should   include "/tmp/work"      
    
    end
    
    it "should change the configuration hash when default ttl is changed" do
           
      @config.cache_fallback_ttl = 808
      @config.download_cache_options[:default_ttl].should == 808
      
    end
    
    it "should allow direct manipulation of the config hash" do
      
      @config.verbose_downloads?.should be_false
      @config.download_cache_options[:verbose].should be_false
           
      @config.download_cache_options[:verbose] = true
      @config.download_cache_options[:verbose].should be_true
        
    end
    
    it "should allow new options to be merged into the default config hash" do
      
      @config.verbose_downloads?.should be_false
      @config.download_cache_options[:verbose].should be_false
           
      @config.download_cache_options = { :verbose => true }
      @config.download_cache_options[:verbose].should be_true
      @config.download_cache_options[:default_ttl].should == 7200
        
    end
    
    it "should allow other, more obscure Rack::Cache options to be set directly" do

      @config.download_cache_options[:allow_reload].should be_nil
      @config.download_cache_options[:allow_revalidate].should be_nil
           
      @config.download_cache_options = { :allow_reload => true }
      @config.download_cache_options[:allow_revalidate] = true
      
      @config.download_cache_options[:allow_reload].should     be_true
      @config.download_cache_options[:allow_revalidate].should be_true
      
      
    end
    
  end
  
end


