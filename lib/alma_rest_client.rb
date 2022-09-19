require "alma_rest_client/version"
require "alma_rest_client/configuration"
require "alma_rest_client/error"
require "alma_rest_client/response"

require "active_support"
require "active_support/core_ext/hash/conversions"
require "logger"
require "faraday"
require "faraday/retry"
require "alma_rest_client/client"

require "alma_rest_client/test/helpers"

module AlmaRestClient
  class << self
    def client(conn=Faraday.new)
      Client.new(conn)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
