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
def stub_alma_get_request(url:, body: "{}",status: 200, query: {})
    stub_request(:get, "#{ENV["ALMA_API_HOST"]}/almaws/v1/#{url}").with( 
      headers: {   
          accept: 'application/json', 
          Authorization: "apikey #{ENV['ALMA_API_KEY']}",
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
      },
      query: query,
    ).to_return(body: body, status: status, headers: {content_type: 'application/json'})   
end

def stub_alma_post_request(url:, body: "{}",status: 200, query: {})
    stub_request(:post, "#{ENV["ALMA_API_HOST"]}/almaws/v1/#{url}").with( 
      headers: {   
          accept: 'application/json', 
          Authorization: "apikey #{ENV['ALMA_API_KEY']}",
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
      },
      query: query,
    ).to_return(body: body, status: status, headers: {content_type: 'application/json'})   
end
def stub_alma_put_request(url:, input:, output:, status: 200)
    stub_request(:put, "#{ENV["ALMA_API_HOST"]}/almaws/v1/#{url}").with( 
      body: input,
      headers: {   
          accept: 'application/json', 
          Authorization: "apikey #{ENV['ALMA_API_KEY']}",
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
      }).to_return(body: output, status: status, headers: {content_type: 'application/json'})   
end
