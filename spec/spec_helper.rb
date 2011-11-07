$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'shibkit/meta_meta'
require 'digest/md5'
require 'logger'

require 'reek/spec'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

URL_REGEX = Regexp.new('(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]')

## Configure RSpec options
RSpec.configure do |config|

  config.include(Reek::Spec)

end

## Set logfile if one is specified in an environment variable, otherwise log to /dev/null to keep things tidy
Shibkit::MetaMeta.config.logger = ENV['SK_LOG_FILE'] ? Logger.new(ENV['SK_LOG_FILE']) : Logger.new("/dev/null") 
