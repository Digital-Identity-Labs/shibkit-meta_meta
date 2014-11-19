require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')
require 'rack/cache'

describe Shibkit::MetaMeta::Config, "download and file caching settings" do
  
  ## Testing a singleton is tricky! Make a copy of the class each time
  before(:each) do
    @config_class = Shibkit::MetaMeta::Config.clone                                                             
    @config = @config_class.instance                                
  end
  
  subject { @config }
  
  it { is_expected.to respond_to :download_cache_options=  }
  it { is_expected.to respond_to :download_cache_options }
  it { is_expected.to respond_to :verbose_downloads= }
  it { is_expected.to respond_to :verbose_downloads? }
  it { is_expected.to respond_to :cache_fallback_ttl= }
  it { is_expected.to respond_to :cache_fallback_ttl }
  it { is_expected.to respond_to :cache_root= }
  it { is_expected.to respond_to :cache_root }
  
  it "should return a hash of cache options" do
    
    expect(@config.download_cache_options).to be_a_kind_of Hash
    
  end
  
  it "cache options should be compatible with Rack::Cache" do
    
    options = @config.download_cache_options
    expect {RestClient.enable Rack::Cache, options}.not_to raise_error
    
  end
  
  it "should represent download cache data and metadata locations as URLs" do
    options = @config.download_cache_options
    expect(options[:metastore]).to   match URL_REGEX
    expect(options[:entitystore]).to match URL_REGEX
  end
  
  context "When using default settings" do
    
    describe "the cache options hash" do

      before(:each) do                                                         
        @cache_options = @config.download_cache_options                                
      end
      
      it "should have a two hour default TTL for cached files" do
        expect(@cache_options[:default_ttl]).to eq(7200)
      end
      
      it "should store cached metadata inside the cache root in a folder called meta" do
        location =  @cache_options[:metastore]
        expect(location).to include @config.cache_root
        expect(location).to include 'meta'
      end
      
      it "should store cached data inside the cache root in a folder called body" do
        location =  @cache_options[:entitystore]
        expect(location).to include @config.cache_root
        expect(location).to include 'body'
      end
      
      it "should have verbose output set to false" do
        expect(@cache_options[:verbose]).to be_falsey
      end
      
    end
    
    it "should have a fallback ttl of two hours" do
      expect(@config.cache_fallback_ttl).to eq(7200)
    end
    
    it "should have the verbose download setting return false" do
      expect(@config.verbose_downloads?).to be_falsey
    end
    
    context "on Windows" do
      
      it "should store cache files in the default TEMP directory" do
        
        allow_any_instance_of(@config_class).to receive(:sensible_os?).and_return(false)
        tempbase = 'c:\Temp'
        ENV['TEMP'] = tempbase
        
        expect(@config.download_cache_options[:entitystore]).to include tempbase.gsub('\\','/')
        
      end
    
    end
    
    context "on sensible operating systems" do
      
      it "should store cache files in /tmp/" do
        
        allow_any_instance_of(@config_class).to receive(:sensible_os?).and_return(true)
        tempbase = '/tmp'
        
        expect(@config.download_cache_options[:entitystore]).to include tempbase
        
      end
      
    end
    
  end
  
  context "When changing settings" do
    
    it "should allow the cache directory to be changed" do
      
      @config.cache_root = "/tmp/bananas"
      expect(@config.cache_root).to eq("/tmp/bananas")
      
    end
    
    it "should change the configuration hash when verbose downloads setting is changed" do
      
      expect(@config.verbose_downloads?).to be_falsey
      expect(@config.download_cache_options[:verbose]).to be_falsey
           
      @config.verbose_downloads = true
      expect(@config.download_cache_options[:verbose]).to be_truthy
      
    end
    
    it "should change the default configuration hash when cache root is changed" do
        
      @config.cache_root = "/tmp/work"
      expect(@config.download_cache_options[:entitystore]).to include "/tmp/work" 
      expect(@config.download_cache_options[:metastore]).to   include "/tmp/work"      
    
    end
    
    context "if an equivalent Rack::Cache setting is configured directing using #download_cache_options" do 
    
      it "should not change the cache storage settings when #cache_root is changed " do
      
        @config.download_cache_options = { :entitystore => 'heap:/' }
        @config.download_cache_options = { :metastore   => 'heap:/' }
      
        @config.cache_root = "/tmp/scratch"
      
        expect(@config.download_cache_options[:entitystore]).to eq('heap:/')
        expect(@config.download_cache_options[:metastore ]).to  eq('heap:/')      
      
      end
      
      it "should always change the configuration hash when #default_ttl is changed" do

        @config.cache_fallback_ttl = 808
        expect(@config.download_cache_options[:default_ttl]).to eq(808)

      end
      
      it "changing the configuration hash does not change #default_ttl" do

        @config.download_cache_options = { :default_ttl => 909 }
        expect(@config.cache_fallback_ttl).not_to eq(909)

      end
      
      it "should always change the configuration hash when #verbose_downloads is changed" do
        
        @config.download_cache_options = { :verbose => false }
        @config.verbose_downloads = true
        expect(@config.download_cache_options[:verbose]).to eq(true)
      
      end
      
      it "changing the configuration hash does not change #verbose_downloads" do
        
        @config.verbose_downloads = true
        @config.download_cache_options = { :verbose => false }
        expect(@config.verbose_downloads?).to eq(true)
      
      end
      
    end
    
    it "should not allow direct manipulation of the returned config hash" do
      
      expect { @config.download_cache_options[:verbose] = true }.to raise_error
        
    end
    
    it "should allow new options to be merged into the default config hash, overloading those controlled by other methods" do
      
      expect(@config.verbose_downloads?).to be_falsey
      expect(@config.download_cache_options[:verbose]).to be_falsey
           
      @config.download_cache_options = { :verbose => true }
      expect(@config.download_cache_options[:verbose]).to be_truthy
      expect(@config.download_cache_options[:default_ttl]).to eq(7200)
        
    end
    
    it "should allow other, more obscure Rack::Cache options to be set" do

      expect(@config.download_cache_options[:allow_reload]).to be_nil
      expect(@config.download_cache_options[:allow_revalidate]).to be_nil
           
      @config.download_cache_options = { :allow_reload => true }
      @config.download_cache_options = { :allow_revalidate => true }
      
      expect(@config.download_cache_options[:allow_reload]).to     be_truthy
      expect(@config.download_cache_options[:allow_revalidate]).to be_truthy
           
    end
    
  end
  
end


