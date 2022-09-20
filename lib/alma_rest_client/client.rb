module AlmaRestClient
  class Client
    def initialize(conn = Faraday.new)
      config = AlmaRestClient.configuration
      @conn = conn
      @conn.headers.merge!({
        "Authorization" => "apikey #{config.alma_api_key}",
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "Cache-Control" => "no-cache",
        "User-Agent" => "Ruby AlmaRestClient"
      })
      @conn.url_prefix = config.alma_api_host

      @conn.builder.build do |f|
        f.request :json
        f.request :retry, config.retry_options
        f.response :json
        f.adapter config.http_adapter
      end
    end
    [:get, :post, :delete, :put].each do |name|
      define_method(name) do |url, options = {}|
        @conn.public_send(name, "/almaws/v1/#{url.sub(/^\//, "")}") do |req|
          options[:query]&.each do |key, value|
            req.params[key] = value
          end
          req.body = options[:body]
        end
      end
    end
    #
    # record_key is the key that holds the array of items
    def get_all(url:, record_key:, limit: 100, query: {})
      get_all_loop(url, record_key, limit, query)
    rescue
      Response.new(status: 500, message: "Could not retrieve items.")
    end

    def get_report(path:, filter: nil, retries: 2, &block)
      query = {path: path, limit: 1000, col_names: true}
      begin
        if block
          start_report(query, retries, &block)
          Response.new(status: 200, message: "success")
        else
          default_report(query, retries)
        end
      rescue => error
        Response.new(status: 500, message: error.to_s)
      end
    end

    private

    def get_columns(xml)
      col_raw = xml&.dig("QueryResult", "ResultXml", "rowset", "schema", "complexType", "sequence", "element")
      col_raw.map { |x| [x["name"], x["saw_sql:columnHeading"]] }.to_h
    end

    def default_report(query, retries)
      output = []
      start_report(query, retries) do |row|
        output.push(row)
      end
      Response.new(body: output)
    end

    def fetch_report_page(query, retries)
      response = get("/analytics/reports", query: query)
      Hash.from_xml(response.body["anies"].first)
    end

    def start_report(query, retries, &block)
      xml = fetch_report_page(query, retries)
      query[:token] = xml.dig("QueryResult", "ResumptionToken")
      columns = get_columns(xml)
      report_loop(xml, columns, query, retries, &block)
    end

    def report_loop(xml, columns, query, retries, &block)
      rows = xml&.dig("QueryResult", "ResultXml", "rowset", "Row") || []
      rows = [rows] if rows.instance_of?(Hash)
      rows.each do |row|
        my_row = {}
        columns.keys.each { |k| my_row[columns[k]] = row[k] }
        block.call(my_row)
      end
      if xml.dig("QueryResult", "IsFinished") != "true"
        xml = fetch_report_page(query, retries)
        report_loop(xml, columns, query, retries, &block)
      end
    end

    # query keys 'limit' and 'offset' will be overwritten
    def get_all_loop(url, record_key, limit, query = {})
      query[:offset] = 0
      query[:limit] = limit
      output = get(url, query: query)
      body = output.body
      while body["total_record_count"] > limit + query[:offset]
        query[:offset] = query[:offset] + limit
        my_output = get(url, query: query)
        my_output.body[record_key].each { |x| body[record_key].push(x) }
      end
      Response.new(body: body) # return good response
    end
  end
end
