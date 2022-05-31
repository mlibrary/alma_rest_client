require "alma_rest_client/version"
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
  def self.client
    Client.new
  end
end
