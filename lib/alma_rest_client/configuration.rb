module AlmaRestClient
  class Configuration
    attr_accessor :alma_api_key, :alma_api_host, :http_adapter, :retry_options
    def initialize
      @alma_api_key = ENV.fetch("ALMA_API_KEY", "")
      @alma_api_host = ENV.fetch("ALMA_API_HOST", "https://api-na.hosted.exlibrisgroup.com")
      @http_adapter = :httpx
      @retry_options = {max: 1, retry_statuses: [500]}
    end
  end
end
