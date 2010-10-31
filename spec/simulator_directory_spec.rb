require 'spec_helper'
require 'shibkit/rack/simulator/models/directory'

describe Shibkit::Rack::Simulator::Model::Directory do
  
  describe "new" do
    
    it "returns a directory object"
  
    describe "when passed an organisation id or object" do

      it "returns a directory only containing users from that organisation"

    end
    
    describe "when passed no object at all" do
      
      it "returns a directory containing all users"
      
    end
    
  end
  
  context "A directory object" do
    
    describe "#authenticate" do
      
      it "requires a username with optional credential (password)"
      it "returns user id when a user is found in the database"
      it "returns nil when a user is not found in the database"
      
    end
    
    describe "#lookup_user" do
      
      it "returns a hash containing user attributes if the user is present"
      it "returns nil if the user is not found"
      
    end
    
    describe "#users" do
      
      it "returns a hash containing all user hashes, keyed on user_id"
      
    end 
   
    describe "#organisation" do

      it "returns the organisation object, or nil if global"

    end
    
  end 
  
end
