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
  
end
