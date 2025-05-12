module AlmaRestClient
  class Configuration
    attr_accessor :alma_api_key, :alma_api_host, :retry_options
    attr_writer :http_adapter
    def initialize
      @alma_api_key = ENV.fetch("ALMA_API_KEY", "")
      @alma_api_host = ENV.fetch("ALMA_API_HOST", "https://api-na.hosted.exlibrisgroup.com")
      @http_adapter = [:httpx]
      @retry_options = {max: 1, retry_statuses: [500]}
    end

    def http_adapter
      [@http_adapter].flatten
    end
  end
end
