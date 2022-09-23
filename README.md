# AlmaRestClient

This gem retrieves Alma data from the Alma API. It extends the HTTParty gem.

## Minimal Installation

Add this line to your application's Gemfile:

```ruby
source "https://rubygems.pkg.github.com/mlibrary" do
  gem "alma_rest_client", "~> 2.0"
end
```

And then execute:
```
$ bundle install
```

Or install it yourself as:
```
$ gem install alma_rest_client
```

Set the API key.

Set the following environment variables
```
ALMA_API_KEY
```

Or directly configure it:
```ruby
AlmaRestClient.configure do |config|
  config.alma_api_key = ENV.fetch("ENV_VAR_WITH_API_KEY")
end
```

## Usage
All of the following methods return a `Faraday::Response` object from Alma

```ruby
#all are instance methods
client = AlmaRestClient.client

# Get method without options
response = client.get('/users/soandso')

# Get method with options
response = client.get('/users/soandso/loans', query: {"limit" => 100, "expand" => "renewable"}

#post method without options
response = client.post('/users/soandso/loans/123958915158')

#post method with options
response = client.post('/users/soandso/loans/123958915158', query: {"op" => "renew"}, body: 'ruby_hash_or_array or string its expecting to receive')

#put method
response = client.put('/users/soandso', body: 'ruby_hash_or_array or json_body_string_alma_is_expecting_to_receive')

```
`get_all` method tries twice to get full list of results from Alma. This returns an AlmaRestClient::Response object which has a code, message, and parsed_response. The full list is of the form of a normal `AlmaRestClient#get` method, if there was a limit "ALL" option. `get_all` method uses keyword arguments. `:url` and `:record_key` are required arguments.

```ruby
#all are instance methods
client = AlmaRestClient.client

#get_all without options
response = client.get_all(url: '/users/soandso/loans', record_key: 'item_loan')

#get_all with options; this method overwrites 'limit' and 'offset'
response = client.get_all(url: '/users/soandso/loans', record_key: 'item_loan', query: {"expand" => "renewable"})
```
`get_report` method is used for working Alma Analytics reports. It takes the argument `:path` which is the path to the analytics report. It can take a block or no block.

When no block is given to `get_report` it returns an `AlmaRestClient::Response` object which has a code, messsage, and parsed_response. The parsed response is an array of report rows. Each row element is a hash where the keys are the column names of the report. 

When a block is given, the block can work with a row of the report. Each row is a hash where the keys are the column names of the report. If it's successful it will return a successful `AlmaRestClient::Response` object.  


```ruby
#all are instance methods
client = AlmaRestClient.client

#get_report
response = client.get_report(path: '/shared/University of Michigan 01UMICH_INST/Reports/fake-data')

my_array = []
response = client.get_report(path: '/shared/University of Michigan 01UMICH_INST/Reports/fake-data') do |row|
  my_array.push(row)
end

#optional 'retries' parameter is for how many times to retry a page of the report. Default is 2.
response = client.get_report(path: '/shared/University of Michigan 01UMICH_INST/Reports/fake-data', retries: 5)
```
## Configuration

### Environment Variables
Configuration of the Alma API Key and the Alma host can be done with the following environment variables

```
ALMA_API_KEY
ALMA_API_HOST
```
### Direct Configuration
The gem can be configured directly with this pattern:

```ruby
AlmaRestClient.configure do |config|
  config.alma_api_key = ENV.fetch("ENV_VAR_WITH_API_KEY")
end
```
Configuring directly overrides the environment variables. 

### Configuration Options
Below are the configuration options and their defaults:
|Name|Description|Default Value|
|---|---|---|
|`alma_api_key`|The Alma API Key that has the appropriate permissions|`""`|
|`alma_api_host`|The base exlibris url | `https://api-na.hosted.exlibrisgroup.com`|
| `http_adapter` | The http adapter for Faraday to use | `:httpx` |
| `retry_options` | A hash of options for the [retry adapter for Faraday](https://github.com/lostisland/faraday-retry) | `{ max: 1, retry_statuses: [500] }` |

## Using a custom Faraday connection object

The `AlmaRestClient::Client` object can be initialized with a `Faraday::Connection` object like so:
```ruby
conn = Faraday.new do
# Whatever special setting you want
end
AlmaRestClient.new(conn)
```
The `adapter` will still be set to whatever is in `http_adapter`. The `retry` adapter must also be configured in the configuration options.

## Rspec Test Helpers
This gem includes `rspec` test helpers. They require the [Webmock library](https://github.com/bblimke/webmock). To use them put the following in your `spec_helper.rb`

```ruby
require "alma_rest_client"
require "webmock/rspec"
require "httpx/adapters/webmock"

Rspec.configure do |config|
  include AlmaRestClient::Test::Helpers
# ....
end
```

This will give you the following stubs:
```
stub_alma_get_request(url:, input:, output:, status:, query:, no_return)
stub_alma_post_request(url:, input:, output:, status:, query:, no_return)
stub_alma_put_request(url:, input:, output:, status:, query:, no_return)
stub_alma_delete_request(url:, input:, output:, status:, query:, no_return)
```
The parameters are described below.
|parameter| description | default|
|---|---|---|
|`url`| The path to the api endpoint that you would use with the actual client | (required) |
|`input`| The body of the input given to the  request | `nil` |
|`output`| The body the stubbed request should return | `nil` |
|`status`| The status the stubbed request should return | `200` |
|`query`| The query parameters that should be part of the stubbed request | `nil` |
|`no_return`| This is for when you want to add to the stub, like `to_raise`. If this is not nil, then `output` will be ignored. | `nil` |


## How to Contribute

Clone the repository and cd into it
```
$ git clone git@github.com:mlibrary/alma_rest_client.git
$ cd alma_rest_client
```

Copy `.env-example` to `.env`
```
$ cp .env-example .env
```

Edit `.env` Replace the value for `ALMA_API_KEY` with a real key with appropriate permissions

Build the image
```
$ docker-compose build
```

Install the gems
```
$ docker-compose run --rm web bundle install
```


Run the tests
```
$ docker-compose run --rm web bundle exec rspec
```

To run the gem in irb
```
$ docker-compose run --rm web bundle exec irb
irb> client = AlmaRestClient.client
```
