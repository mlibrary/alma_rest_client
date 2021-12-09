require "alma_rest_client/version"
require 'httparty'
require 'active_support/core_ext/hash/conversions'

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
  class ClientBase
    include HTTParty
    base_uri "#{ENV.fetch('ALMA_API_HOST')}/almaws/v1"

    def initialize()
      self.class.headers 'Authorization' => "apikey #{ENV.fetch('ALMA_API_KEY')}"
      self.class.headers 'Accept' => 'application/json'
      self.class.headers 'Content-Type' => 'application/json'
    end

    [:get, :post, :delete, :put].each do |name|
      define_method(name) do |url, options={}|
        self.class.public_send(name, url, options)
      end
    end
  end
  class Client 
    extend Forwardable
    def_delegators :@base_client, :get, :post, :delete, :put
    def initialize(base_client=ClientBase.new)
      @base_client = base_client
    end

    #record_key is the key that holds the array of items 
    def get_all(url:, record_key:, limit: 100, query: {})
      try_count = 1
      begin
        get_all_loop(url, record_key, limit, query)
      rescue
        Response.new(code: 500, message: 'Could not retrieve items.')
      end
    end 

    def get_report(path:, filter: nil, &block)
      query = { path: path, limit: 1000, col_names: true}

      begin 
        if block_given?
          start_report(**query, &block)
          return Response.new(code: 200, message: 'success')
        else
          default_report(**query)
        end
      rescue 
        return Response.new(code: 500, message: 'Could not retrieve report.')
      end
    end

    private
    def get_columns(xml)
      col_raw = xml["QueryResult"]["ResultXml"]["rowset"]["schema"]["complexType"]["sequence"]["element"]
      cols = col_raw.map {|x| [x["name"],  x["saw_sql:columnHeading"]] }.to_h
    end

    def default_report(query)
      output = []
      start_report(query) do |row|
        output.push(row)
      end
      Response.new(parsed_response: output)
    end
    def fetch_report_page(query)
      try_count = 1
      begin
        response = get("/analytics/reports", query: query)
        Hash.from_xml(response.parsed_response["anies"].first)
      rescue
        try_count += 1
        retry if try_count <= 2
      end
    end
    def start_report(query, &block)
      xml = fetch_report_page(query)
      query[:token] = xml["QueryResult"]["ResumptionToken"]
      columns = get_columns(xml)
      report_loop(xml, columns, query, &block) 
    end
    def report_loop(xml, columns, query, &block)
      rows = xml["QueryResult"]["ResultXml"]["rowset"]["Row"]
      rows = [ rows ] if rows.class == Hash
      rows.each do |row|
        my_row = {}
        row.keys.each {|k| my_row[columns[k]] = row[k] }
        block.call(my_row)
      end
      if xml["QueryResult"]["IsFinished"] != 'true'
        xml = fetch_report_page(query)
        report_loop(xml, columns, query, &block)
      end
    end
    def fetch_results_page(url, query)
      try_count = 1
      begin
        response = get(url, query: query) 
        raise StandardError if response.code != 200
        response
      rescue
        try_count += 1
        retry if try_count <= 2
      end
    end
    #query keys 'limit' and 'offset' will be overwritten
    def get_all_loop(url, record_key, limit, query={})
      query[:offset] = 0 
      query[:limit] = limit
      output = fetch_results_page(url, query)
      body = output.parsed_response
      while  body['total_record_count'] > limit + query[:offset]
        query[:offset] = query[:offset] + limit
        my_output = fetch_results_page(url, query) 
        my_output.parsed_response[record_key].each {|x| body[record_key].push(x)}
      end
      Response.new(parsed_response: body) #return good response
    end
  end


  def self.client
    Client.new
  end
end
