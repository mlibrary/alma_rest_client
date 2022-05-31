module AlmaRestClient
  module Test
    module Helpers
      [:get, :post, :put, :delete].each do |name|
        define_method("stub_alma_#{name}_request") do |url:, input: nil, output: "", status: 200, query: nil|
          req_attributes = {}
          req_attributes[:headers] = {
            :accept => "application/json",
            :Authorization => "apikey #{AlmaRestClient.configuration.alma_api_key}",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Content-Type" => "application/json",
            "User-Agent" => "Faraday v2.3.0",
            "Cache-Control" => "no-cache"
          }
          req_attributes[:body] = input unless input.nil?
          req_attributes[:query] = query unless query.nil?
          resp = {headers: {content_type: "application/json"}, status: status, body: output}

          stub_request(name, "#{AlmaRestClient.configuration.alma_api_host}/almaws/v1/#{url}").with(**req_attributes).to_return(**resp)
        end
      end
    end
  end
end
