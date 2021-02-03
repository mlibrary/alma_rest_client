RSpec.describe AlmaRestClient do
  it "has a version number" do
    expect(AlmaRestClient::VERSION).not_to be nil
  end

  context ".client" do
    it "returns an AlmaRestClient::Client object" do
      expect(described_class.client.class.name).to eq("AlmaRestClient::Client")
    end
  end
end

RSpec.describe AlmaRestClient::Client do
  subject do
    described_class.new
  end
  context "#get(url, query={})" do
    it "returns HTTParty response for only url" do
      stub_alma_get_request(url: 'users/soandso')
      expect(subject.get('/users/soandso').class.name).to eq("HTTParty::Response")
    end
    it "returns HTTParty response for url and parameters" do
      stub_alma_get_request(url: 'users/soandso/loans', query: {"limit" => 100})
      expect(subject.get('/users/soandso/loans', {"limit" => 100}).class.name).to eq("HTTParty::Response")
    end
  end
  context "#post(url, query={})" do
    it "returns HTTParty response for only url" do
      stub_alma_post_request(url: 'users/soandso/loans')
      expect(subject.post('/users/soandso/loans').class.name).to eq("HTTParty::Response")
    end
    it "returns HTTParty response for url and parameters" do
      stub_alma_post_request(url: 'users/soandso/loans', query: {"op" => "renew"})
      expect(subject.post('/users/soandso/loans', {"op" => "renew"}).class.name).to eq("HTTParty::Response")
    end
  end
  context "#put(url, body)" do
    it "returns HTTParty response for url and body" do
      input = 'iamastring'.to_json
      stub_alma_put_request(url: 'users/soandso', input: input, output: "{}" )
      expect(subject.put('/users/soandso', input).class.name).to eq("HTTParty::Response")
    end
  end
  context "#get_all(url, record_key, limit, query)" do
    it "makes multiple calls to the alma server and returns appropriate response." do
      url = "users/jbister/loans"
      stub_alma_get_request( query: { "limit" => 1, "offset" => 0}, body: File.read("./spec/fixtures/jbister_loans0.json"), url: url) 
      stub_alma_get_request( query: { "limit" => 1, "offset" => 1}, body: File.read("./spec/fixtures/jbister_loans1.json"), url: url) 

      response = described_class.new.get_all("/#{url}", "item_loan", 1)
      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.code).to eq(200)
      expect(response.parsed_response["item_loan"].count).to eq(2)
    end
    it "if alma requests fail to get everything, it tries again and if it fails again it returns an error" do
      url = "users/jbister/loans"
      stub1 = stub_alma_get_request( query: { "limit" => 1, "offset" => 0}, body: File.read("./spec/fixtures/jbister_loans0.json"), url: url) 
      stub2 = stub_alma_get_request( query: { "limit" => 1, "offset" => 1}, body: "", url: url, status: 500) 
      response = described_class.new.get_all("/#{url}", "item_loan", 1)
      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.code).to eq(500)
      expect(response.message).to eq('Could not retrieve items.')
      expect(stub1).to have_been_requested.times(2)
      expect(stub2).to have_been_requested.times(2)
    end
    it "if alma requests fail to get everything the first time, it tries again and if it succeeds returns successful full results" do
      url = "users/jbister/loans"
      stub1 = stub_alma_get_request( query: { "limit" => 1, "offset" => 0}, body: File.read("./spec/fixtures/jbister_loans0.json"), url: url) 
      stub2 = stub_alma_get_request( query: { "limit" => 1, "offset" => 1}, body: "", url: url, status: 500) 
      stub2.then.to_return({body: File.read("./spec/fixtures/jbister_loans1.json"), status: 200, headers: {content_type: 'application/json'}}) 

      response = described_class.new.get_all("/#{url}", "item_loan", 1)
      expect(stub1).to have_been_requested.times(2)
      expect(stub2).to have_been_requested.times(2)

      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.code).to eq(200)
      expect(response.parsed_response["item_loan"].count).to eq(2)
    end

  end
  
end
