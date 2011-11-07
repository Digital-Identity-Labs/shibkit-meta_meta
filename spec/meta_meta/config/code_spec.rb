require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Shibkit::MetaMeta::Config, "class source code quality" do

  it 'contains no code smells' do
    
    source_code = File.expand_path(File.dirname(__FILE__) + '../../../../lib/shibkit/meta_meta/config.rb')
    
    source_code.should_not reek
  
  end
  
end