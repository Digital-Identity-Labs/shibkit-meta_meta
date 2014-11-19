require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Source, "additional information for applications" do
  
  ## 
  before(:each) do                                                       
    @source = Shibkit::MetaMeta::Source.new
  end

  subject { @source }
  
  it { is_expected.to respond_to :groups=  }
  it { is_expected.to respond_to :groups }
  it { is_expected.to respond_to :tags= }
  it { is_expected.to respond_to :tags }
  it { is_expected.to respond_to :trustiness= }
  it { is_expected.to respond_to :trustiness }
  
  it "should accept strings as group names" do
    
    @source.groups = ['one', 'two', 'three']
    expect(@source.groups).to match_array([:one, :two, :three])
    
  end

  it "should accept symbols for group names" do
    
    @source.groups = [:one, :two, :three]
    expect(@source.groups).to match_array([:one, :two, :three])
    
  end
  
  it "should accept a single group as a string" do
    
    @source.groups = :one
    expect(@source.groups).to match_array([:one])
    
  end

  it "should accept an array of groups" do

    @source.groups = [:one, :two]
    expect(@source.groups).to match_array([:one, :two])
    
  end
  
  it "should replace previously assigned groups with assigned groups" do
    
    @source.groups = :elephant
    expect(@source.groups).to match_array([:elephant])
    
    @source.groups = [:one, :two]
    expect(@source.groups).to match_array([:one, :two])
    
  end
  
  it "should always return an array of groups" do
    
    @source.groups = :elephant
    expect(@source.groups).to be_kind_of Array
    
    @source.groups = [:one, :two]
    expect(@source.groups).to be_kind_of Array
    
  end
  
  it "should always return group names as downcased symbols" do
    
    @source.groups = :elephant
    expect(@source.groups).to match_array([:elephant])
    
    @source.groups = :MONKEY
    expect(@source.groups).to match_array([:monkey])

    @source.groups = 'hippo'
    expect(@source.groups).to match_array([:hippo])
    
    @source.groups = 'BEAR'
    expect(@source.groups).to match_array([:bear])

  end
   
  it "should accept strings as tag names" do
   
    @source.tags = ['one', 'two', 'three']
    expect(@source.tags).to match_array([:one, :two, :three])
   
  end

  it "should accept symbols for tag names" do
   
    @source.tags = [:one, :two, :three]
    expect(@source.tags).to match_array([:one, :two, :three])
   
  end
 
  it "should accept a single tag as a string" do
   
    @source.tags = :one
    expect(@source.tags).to match_array([:one])
   
  end

  it "should accept an array of tags" do

    @source.tags = [:one, :two]
    expect(@source.tags).to match_array([:one, :two])
   
  end
 
  it "should replace previously assigned tags with assigned tags" do
   
    @source.tags = :elephant
    expect(@source.tags).to match_array([:elephant])
   
    @source.tags = [:one, :two]
    expect(@source.tags).to match_array([:one, :two])
   
  end
 
  it "should always return an array of tags" do
   
    @source.tags = :elephant
    expect(@source.tags).to be_kind_of Array
   
    @source.tags = [:one, :two]
    expect(@source.tags).to be_kind_of Array
   
  end
 
  it "should always return tag names as downcased symbols" do
   
    @source.tags = :elephant
    expect(@source.tags).to match_array([:elephant])
   
    @source.tags = :MONKEY
    expect(@source.tags).to match_array([:monkey])

    @source.tags = 'hippo'
    expect(@source.tags).to match_array([:hippo])
   
    @source.tags = 'BEAR'
    expect(@source.tags).to match_array([:bear])

  end
  
  it "should accept floating point decimal fractions as trustiness" do
    
    dfs = [0.1,0.0,0.4,0.9,1.0].each do |df|
    
      @source.trustiness = df
      expect(@source.trustiness).to eq(df)
    
    end
    
  end
   
  it "should accept strings starting with numbers followed by a percentage" do
    
    @source.trustiness = "50%"
    expect(@source.trustiness).to eq(0.5)
    
    @source.trustiness = "70 %"
    expect(@source.trustiness).to eq(0.7)
    
  end
  
  it "should accept strings with numbers as trustiness and trim before converting to floating point" do
    
    @source.trustiness = "5 things"
    expect(@source.trustiness).to eq(1.0)
    
    @source.trustiness = "80"
    expect(@source.trustiness).to eq(1.0)
    
  end
  
  it "should store numbers greater than 1 as 1.0" do
    
    @source.trustiness = 100
    expect(@source.trustiness).to eq(1.0)
    
    @source.trustiness = 5
    expect(@source.trustiness).to eq(1.0)
    
    
  end
  
  it "should store numbers less than 0 as 0.0" do
    
    @source.trustiness = -100
    expect(@source.trustiness).to eq(0.0)
    
    @source.trustiness = -5
    expect(@source.trustiness).to eq(0.0)
    
  end
  
  it "should only return trustiness of between 0 and 1, as a floating point number/decimal fraction" do
    
    @source.trustiness = 100
    expect(@source.trustiness).to be_kind_of Float
    
    @source.trustiness = 0.5
    expect(@source.trustiness).to be_kind_of Float
    
    @source.trustiness = -5
    expect(@source.trustiness).to be_kind_of Float
    
  end
  
  context "by default" do
    
    it "should return 1.0 as the default trustiness" do
      
      expect(@source.trustiness).to eq(1.0)
      
    end
    
    it "should return an empty array as groups" do
      
      expect(@source.groups).to match_array([])
      
    end
    
    it "should return an empty array as tags" do
      
      expect(@source.tags).to match_array([])
      
    end
    
  end
  
end