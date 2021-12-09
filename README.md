# AlmaRestClient

This gem retrieves Alma data from the Alma API. It extends the HTTParty gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'alma_rest_client',
  git: 'https://github.com/mlibrary/alma_rest_client', 
  tag: '1.0.1' #this is the github release tag. It should match the gem version number. 
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install alma_rest_client

Set the following environment variables
```
ALMA_API_HOST
ALMA_API_KEY
```
## Usage
All of the following methods return an HTTParty::Response from Alma
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
response = client.post('/users/soandso/loans/123958915158', query: {"op" => "renew"}, body: 'string its expecting to receive')

#put method
response = client.put('/users/soandso', body: 'json_body_string_alma_is_expecting_to_receive')

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
```

## How to Contribute

Copy .env-example to .env
```
$ cp .env-example .env
```

Replace the value for `ALMA_API_KEY` with a real key with appropriate permissions

Build the image
```
$ docker-compose build
```

Run the tests
```
$ docker-compose run --rm web bundle exec rspec
```
