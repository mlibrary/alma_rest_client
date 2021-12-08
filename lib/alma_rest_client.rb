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

    def get_report(path:, filter: nil)
      query = { path: path, limit: 1000, col_names: true}
      try_count = 1
      begin 
        report_loop(**query)
      rescue 
        if try_count < 2
          try_count = try_count+1
          retry
        else
          return Response.new(code: 500, message: 'Could not retrieve report.')
        end
      end
    end

    private
    def get_columns(xml)
      col_raw = xml["QueryResult"]["ResultXml"]["rowset"]["schema"]["complexType"]["sequence"]["element"]
      cols = col_raw.map {|x| [x["name"],  x["saw_sql:columnHeading"]] }.to_h
    end

    def report_loop(path:,limit:,col_names:)
      output = []
      query = {path: path, limit: limit, col_names: col_names }
      start_report(query) do |row|
        output.push(row)
      end
      Response.new(parsed_response: output)
    end
    def start_report(query, &block)
      response = get("/analytics/reports", query: query)

      xml_string = response.parsed_response["anies"].first
      xml = Hash.from_xml(xml_string)
      query[:token] = xml["QueryResult"]["ResumptionToken"]
      columns = get_columns(xml)
      report_actual_loop(xml, columns, query, &block) 
    end
    def report_actual_loop(xml, columns, query, &block)
        rows = xml["QueryResult"]["ResultXml"]["rowset"]["Row"]
        rows = [ rows ] if rows.class == Hash
        rows.each do |row|
          my_row = {}
          row.keys.each {|k| my_row[columns[k]] = row[k] }
          block.call(my_row)
        end
        if xml["QueryResult"]["IsFinished"] != 'true'
          response = get("/analytics/reports", query: query)
          xml = Hash.from_xml(response.parsed_response["anies"].first)
          report_actual_loop(xml, columns, query, &block)
        end
    end
    #query keys 'limit' and 'offset' will be overwritten
    def get_all_loop(url, record_key, limit, query={})
      query[:offset] = 0 
      query[:limit] = limit
      output = get(url, query: query)
      if output.code == 200
        body = output.parsed_response
        while  body['total_record_count'] > limit + query[:offset]
          query[:offset] = query[:offset] + limit
          my_output = get(url, query: query) 
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
