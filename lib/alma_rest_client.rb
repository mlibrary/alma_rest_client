require "alma_rest_client/version"
require 'httparty'

module AlmaRestClient
  class Error < StandardError; end
  # Your code goes here...
  class Response
    attr_reader :code, :message, :parsed_response
    def initialize(code: 200, message: 'Success', parsed_response: {})
      @code = code
      @message = message
      @parsed_response = parsed_response
    end
  end
  class Client
    include HTTParty
    base_uri "#{ENV.fetch('ALMA_API_HOST')}/almaws/v1"

    def initialize()
      self.class.headers 'Authorization' => "apikey #{ENV.fetch('ALMA_API_KEY')}"
      self.class.headers 'Accept' => 'application/json'
    end

    def get(url, query={})
      self.class.get(url, query: query)
    end
    def post(url, query={})
      self.class.post(url, query: query)
    end

    #requires valid json for the body
    def put(url, body)
      self.class.headers 'Content-Type' => 'application/json'
      self.class.put(url, { body: body } )
    end

    #record_key is the key that holds the array of items 
    def get_all(url, record_key, limit=100, query={})
      try_count = 1
      while try_count <= 2
        response = get_all_loop(url, record_key, limit, query)
        if response.code == 200
          return response
        else
          try_count = try_count + 1
        end
      end
      Response.new(code: 500, message: 'Could not retrieve items.')
    end 

    private
    #query keys 'limit' and 'offset' will be overwritten
    def get_all_loop(url, record_key, limit, query={})
      query[:offset] = 0 
      query[:limit] = limit
      output = get(url, query)
      if output.code == 200
        body = output.parsed_response
        while  body['total_record_count'] > limit + query[:offset]
          query[:offset] = query[:offset] + limit
          my_output = get(url, query) 
          if my_output.code == 200
            my_output.parsed_response[record_key].each {|x| body[record_key].push(x)}
          else
            return Response.new(code: 500, message: 'Could not retrieve items.')
          end
        end 
        Response.new(parsed_response: body) #return good response
      else
        return Response.new(code: 500, message: 'Could not retrieve items.')
      end
    end
  end


  def self.client
    Client.new
  end
end
