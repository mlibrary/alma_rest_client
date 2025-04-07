module AlmaRestClient
  module Test
    module Helpers
      [:get, :post, :put, :delete].each do |name|
        define_method(:"stub_alma_#{name}_request") do |url:, input: nil, output: "", status: 200, query: nil, no_return: nil|
          req_attributes = {}
          req_attributes[:headers] = {
            "Authorization" => "apikey #{AlmaRestClient.configuration.alma_api_key}"
          }
          req_attributes[:body] = input unless input.nil?
          req_attributes[:query] = query unless query.nil?

          resp = {headers: {content_type: "application/json"}, status: status, body: output}

          req = stub_request(name, "#{AlmaRestClient.configuration.alma_api_host}/almaws/v1/#{url.sub(/^\//, "")}").with(**req_attributes)
          req.to_return(**resp) if no_return.nil?
          req
        end
      end
    end
  end
end
