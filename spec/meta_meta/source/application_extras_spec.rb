require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Source, "additional information for applications" do
  
  ## 
  before(:each) do                                                       
    @source = Shibkit::MetaMeta::Source.new
  end

  subject { @source }
  
  it { should respond_to :groups=  }
  it { should respond_to :groups }
  it { should respond_to :tags= }
  it { should respond_to :tags }
  it { should respond_to :trustiness= }
  it { should respond_to :trustiness }
  
  it "should accept strings as group names" do
    
    @source.groups = ['one', 'two', 'three']
    @source.groups.should =~ [:one, :two, :three]
    
  end

  it "should accept symbols for group names" do
    
    @source.groups = [:one, :two, :three]
    @source.groups.should =~ [:one, :two, :three]
    
  end
  
  it "should accept a single group as a string" do
    
    @source.groups = :one
    @source.groups.should =~ [:one]
    
  end

  it "should accept an array of groups" do

    @source.groups = [:one, :two]
    @source.groups.should =~ [:one, :two]
    
  end
  
  it "should replace previously assigned groups with assigned groups" do
    
    @source.groups = :elephant
    @source.groups.should =~ [:elephant]
    
    @source.groups = [:one, :two]
    @source.groups.should =~ [:one, :two]
    
  end
  
  it "should always return an array of groups" do
    
    @source.groups = :elephant
    @source.groups.should be_kind_of Array
    
    @source.groups = [:one, :two]
    @source.groups.should be_kind_of Array
    
  end
  
  it "should always return group names as downcased symbols" do
    
    @source.groups = :elephant
    @source.groups.should =~ [:elephant]
    
    @source.groups = :MONKEY
    @source.groups.should =~ [:monkey]

    @source.groups = 'hippo'
    @source.groups.should =~ [:hippo]
    
    @source.groups = 'BEAR'
    @source.groups.should =~ [:bear]

  end
   
  it "should accept strings as tag names" do
   
    @source.tags = ['one', 'two', 'three']
    @source.tags.should =~ [:one, :two, :three]
   
  end

  it "should accept symbols for tag names" do
   
    @source.tags = [:one, :two, :three]
    @source.tags.should =~ [:one, :two, :three]
   
  end
 
  it "should accept a single tag as a string" do
   
    @source.tags = :one
    @source.tags.should =~ [:one]
   
  end

  it "should accept an array of tags" do

    @source.tags = [:one, :two]
    @source.tags.should =~ [:one, :two]
   
  end
 
  it "should replace previously assigned tags with assigned tags" do
   
    @source.tags = :elephant
    @source.tags.should =~ [:elephant]
   
    @source.tags = [:one, :two]
    @source.tags.should =~ [:one, :two]
   
  end
 
  it "should always return an array of tags" do
   
    @source.tags = :elephant
    @source.tags.should be_kind_of Array
   
    @source.tags = [:one, :two]
    @source.tags.should be_kind_of Array
   
  end
 
  it "should always return tag names as downcased symbols" do
   
    @source.tags = :elephant
    @source.tags.should =~ [:elephant]
   
    @source.tags = :MONKEY
    @source.tags.should =~ [:monkey]

    @source.tags = 'hippo'
    @source.tags.should =~ [:hippo]
   
    @source.tags = 'BEAR'
    @source.tags.should =~ [:bear]

  end
  
  it "should accept floating point decimal fractions as trustiness" do
    
    dfs = [0.1,0.0,0.4,0.9,1.0].each do |df|
    
      @source.trustiness = df
      @source.trustiness.should == df
    
    end
    
  end
   
  it "should accept strings starting with numbers followed by a percentage" do
    
    @source.trustiness = "50%"
    @source.trustiness.should == 0.5
    
    @source.trustiness = "70 %"
    @source.trustiness.should == 0.7
    
  end
  
  it "should accept strings with numbers as trustiness and trim before converting to floating point" do
    
    @source.trustiness = "5 things"
    @source.trustiness.should == 1.0
    
    @source.trustiness = "80"
    @source.trustiness.should == 1.0
    
  end
  
  it "should store numbers greater than 1 as 1.0" do
    
    @source.trustiness = 100
    @source.trustiness.should == 1.0
    
    @source.trustiness = 5
    @source.trustiness.should == 1.0
    
    
  end
  
  it "should store numbers less than 0 as 0.0" do
    
    @source.trustiness = -100
    @source.trustiness.should == 0.0
    
    @source.trustiness = -5
    @source.trustiness.should == 0.0
    
  end
  
  it "should only return trustiness of between 0 and 1, as a floating point number/decimal fraction" do
    
    @source.trustiness = 100
    @source.trustiness.should be_kind_of Float
    
    @source.trustiness = 0.5
    @source.trustiness.should be_kind_of Float
    
    @source.trustiness = -5
    @source.trustiness.should be_kind_of Float
    
  end
  
  context "by default" do
    
    it "should return 1.0 as the default trustiness" do
      
      @source.trustiness.should == 1.0
      
    end
    
    it "should return an empty array as groups" do
      
      @source.groups.should =~ []
      
    end
    
    it "should return an empty array as tags" do
      
      @source.tags.should =~ []
      
    end
    
  end
  
end