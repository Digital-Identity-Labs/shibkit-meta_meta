require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

## Testing a singleton is tricky! Make a copy of the class each time
before(:each) do
  @config_class = Shibkit::MetaMeta::Config.clone                                                             
  @config = @config_class.instance                                
end

