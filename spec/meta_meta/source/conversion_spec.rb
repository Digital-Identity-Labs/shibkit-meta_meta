require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures.rb')

describe Shibkit::MetaMeta::Source, "conversion to and from other classes" do
  
  #require File.expand_path(File.dirname(__FILE__) + '/fixtures')
  
  ## 
  before(:each) do                                                       
    @source = Shibkit::MetaMeta::Source.new
    @class  = Shibkit::MetaMeta::Source
  end
 
  describe "the Source class" do
    
    it "should respond to from_hash" do
      
      Shibkit::MetaMeta::Source.should respond_to :from_hash
      
    end
    
    #it "should be able to create a new Source object from a Hash" do
    #  
    #  Shibkit::MetaMeta::Source.from_hash({})
    #  
    #end 

  end
    
  subject { @source }

  it { should respond_to :to_hash }
  it { should respond_to :to_federation }
  it { should respond_to :to_s }
  
  it "should be able to output a hash" do
    @source.to_hash.should be_kind_of Hash
  end

  describe "the saved hash" do
    
    @parent = TYPICAL_SOURCE_OBJECT
    
    it "should have all keys as symbols" do
    end

    it "should have the same name_uri"
    it "should have the same name"     
    it "should have the same refresh_delay (stored as epoch seconds)" 
    it "should have the same display_name"
    it "should have the same type"     
    it "should have the same countries"
    it "should have the same metadata_source"
    it "should have the same certificate_source" 
    it "should have the same fingerprint" 
    it "should have the same refeds_info"
    it "should have the same homepage"
    it "should have the same languages" 
    it "should have the same support_email"
    it "should have the same description" 
    it "should have the same active" 
    it "should have the same trustiness" 
    it "should have the same groups" 
    it "should have the same tags"   
    
  end
  
  it "should be able to create a federation object" do
    @source.to_federation.class.should be_kind_of Federation
  end
  
  describe "the federation object" do
    
  end
  
  it "should have a special to_s method that is its URI" do
    @source.to_s.should == @source.uri
  end
  
end



