module AlmaRestClient
  class Response
    attr_reader :status, :message, :body
    def initialize(status: 200, message: "Success", body: {})
      @status = status
      @message = message
      @body = body
    end
  end
end
