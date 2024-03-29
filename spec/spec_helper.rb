require "bundler/setup"
require "alma_rest_client"
require "webmock/rspec"
require "byebug"
require "simplecov"
require "climate_control"
require "httpx/adapters/webmock"

SimpleCov.start
RSpec.configure do |config|
  include AlmaRestClient::Test::Helpers
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
def with_modified_env(options = {}, &block)
  ClimateControl.modify(options, &block)
end
