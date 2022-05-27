require "bundler/setup"
require "alma_rest_client"
require "webmock/rspec"
require "byebug"
require "simplecov"
SimpleCov.start
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
[:get, :post,:put, :delete].each do |name|
  define_method("stub_alma_#{name}_request") do |url:, input: nil, output: "", status: 200, query: nil|
    req_attributes = Hash.new
    req_attributes[:headers] = {   
      accept: 'application/json', 
      Authorization: "apikey #{ENV['ALMA_API_KEY']}",
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type' => 'application/json',
      'User-Agent'=>'Faraday v2.3.0',
      'Cache-Control' => 'no-cache'
    }
    req_attributes[:body] = input unless input.nil?
    req_attributes[:query] = query unless query.nil?
    resp = { headers: {content_type: 'application/json'}, status: status, body: output }

    stub_request(name, "#{ENV["ALMA_API_HOST"]}/almaws/v1/#{url}").with( **req_attributes).to_return(**resp)   
  end
end
