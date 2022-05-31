module AlmaRestClient
  class Configuration
    attr_accessor :alma_api_key, :alma_api_host
    def initialize
      @alma_api_key = ENV.fetch("ALMA_API_KEY", "")
      @alma_api_host = ENV.fetch("ALMA_API_HOST", "https://api-na.hosted.exlibrisgroup.com")
    end
  end
end
