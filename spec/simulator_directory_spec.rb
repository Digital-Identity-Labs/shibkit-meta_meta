require 'spec_helper'

describe Shibkit::Rack::Simulator::Model::Directory do
  
  context "In normal use" do
    
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
   
    describe "#organisations" do

      it "returns a hash of hashes containing organisation information"

    end
    
    describe "#federations" do

      it ""

    end
    
  end 
  
end
