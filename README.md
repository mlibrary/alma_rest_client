# AlmaRestClient

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/alma_rest_client`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'alma_rest_client'
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
All methods return an HTTParty parsed response from Alma
```ruby
#all are instance methods
client = AlmaRestClient.client

# Get method without options
user = client.get('/users/soandso')

# Get method with options
loans = client.get('/users/soandso/loans', {"limit" => 100, "expand" => "renewable"}


```
