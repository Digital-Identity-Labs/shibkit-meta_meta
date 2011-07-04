require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'shibkit/metameta/source'

describe Shibkit::MetaMeta::Source do
  
  shared_examples "any source object" do
  
    describe "#name_uri" do
    
      it ""
      it ""

    end
  
    describe "#name" do
    
      it ""
      it ""

    end
  
    describe "#display_name" do
    
      it ""
      it ""

    end

  
    describe "#type" do
    
      it ""
      it ""

    end

  
    describe "#refresh_delay" do
    
      it ""
      it ""

    end

  
    describe "#countries" do
    
      it ""
      it ""

    end

  
    describe "#metadata_source" do
    
      it ""
      it ""

    end

  
    describe "#certificate_source" do
    
      it ""
      it ""

    end

  
    describe "#fingerprint" do
    
      it ""
      it ""

    end

  
    describe "#refeds_info" do
    
      it ""
      it ""

    end

  
    describe "#homepage" do
    
      it ""
      it ""

    end

  
    describe "#languages" do
    
      it ""
      it ""

    end

  
    describe "#support_email" do
    
      it ""
      it ""

    end

  
    describe "#description" do
    
      it ""
      it ""

    end

  
    describe "#uuid" do
    
      it ""
      it ""

    end

  
    describe "#fetched_at" do
    
      it ""
      it ""

    end

  
    describe "#messages" do
    
      it ""
      it ""

    end

  
    describe "#status" do
    
      it ""
      it ""

    end

  
    describe "#refresh" do
    
      it ""
      it ""

    end

  
    describe "#fetch_metadata" do
    
      it ""
      it ""

    end

  
    describe "#fetch_certificate" do
    
      it ""
      it ""

    end

  
    describe "#validate" do
    
      it ""
      it ""

    end

  
    describe "#valid?" do
    
      it ""
      it ""

    end

  
    describe "#certificate_pem" do
    
      it ""
      it ""

    end

  
    describe "#content" do
    
      it ""
      it ""

    end

  
    describe "#ok?" do
    
      it ""
      it ""

    end

  end
  
  shared_examples "a federation" do
    
  end
  
  
  shared_examples "a collection" do
    
  end
  
  
  shared_examples "a remote source" do
    
  end
  
  
  shared_examples "a local source" do
    
  end
  
  context "created with default values" do
    
    it_behaves_like "any source object"
    
  end
  
  context "manually defined as a federation with remote metadata" do
    
    it_behaves_like "any source object"
    it_behaves_like "a federation"
    it_behaves_like "a remote source"
    
  end
  
  context "manually defined as a federation with local metadata" do
    
    it_behaves_like "any source object"
    it_behaves_like "a federation"
    it_behaves_like "a local source"
    
  end
  
  context "manually defined as a collection with local metadata" do
    
    it_behaves_like "any source object"
    it_behaves_like "a collection"
    it_behaves_like "a local source"
    
  end
  
  context "manually defined as a collection with remote metadata" do
    
    it_behaves_like "any source object"
    it_behaves_like "a collection"
    it_behaves_like "a remote source"
  end
  
  context "a collection loaded from the dev sourcefile" do
    
    it_behaves_like "any source object"
    it_behaves_like "a collection"
    
  end
  
  context "a federation loaded from the dev sourcefile" do
    
    it_behaves_like "any source object"
    it_behaves_like "a federation"
    
  end
  
  context "a collection loaded from the real sourcefile" do
    
    it_behaves_like "any source object"
    it_behaves_like "a collection"
    
  end
  
  context "a federation loaded from the real sourcefile" do
    
    it_behaves_like "any source object"
    it_behaves_like "a federation"
    
  end
  
  
  
  
  describe "Source#config" do
    
    it ""
    it ""

  end

  
  describe "Source#load" do
    
    it ""
    it ""

  end

  
  describe "Source#cache_options" do
    
    it ""
    it ""

  end

  
  describe "Source#environment" do
    
    it ""
    it ""

  end

  
  describe "Source#verbose?" do
    
    it ""
    it ""

  end

  
  describe "Source#auto_refresh" do
    
    it ""
    it ""

  end

  
  describe "Source#log_file" do
    
    it ""
    it ""

  end

end
