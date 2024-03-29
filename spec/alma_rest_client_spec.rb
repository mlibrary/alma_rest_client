RSpec.describe AlmaRestClient::Client do
  subject do
    described_class.new
  end
  context "#get(url, query: {})" do
    it "returns Faraday response for only url" do
      stub_alma_get_request(url: "users/soandso")
      expect(subject.get("/users/soandso").class.name).to eq("Faraday::Response")
    end
    it "returns Faraday response for url and parameters" do
      stub_alma_get_request(url: "users/soandso/loans", query: {"limit" => 100})
      expect(subject.get("/users/soandso/loans", query: {"limit" => 100}).class.name).to eq("Faraday::Response")
    end
  end
  context "#post(url, {query:, body:})" do
    it "returns Faraday response for only url" do
      stub_alma_post_request(url: "users/soandso/loans")
      expect(subject.post("/users/soandso/loans").class.name).to eq("Faraday::Response")
    end
    it "returns Faraday response for url and parameters" do
      stub_alma_post_request(url: "users/soandso/loans", query: {"op" => "renew"})
      expect(subject.post("/users/soandso/loans", query: {"op" => "renew"}).class.name).to eq("Faraday::Response")
    end
    it "handles query and body" do
      stub_alma_post_request(url: "users/soandso/loans", query: {"op" => "hold"}, input: {thing: "stuff"})
      expect(subject.post("/users/soandso/loans", query: {"op" => "hold"}, body: {thing: "stuff"}.to_json).class.name).to eq("Faraday::Response")
    end
  end
  context "#delete(url, query: {})" do
    it "returns Faraday response for only url" do
      stub_alma_delete_request(url: "users/soandso/requests/12345")
      expect(subject.delete("/users/soandso/requests/12345").class.name).to eq("Faraday::Response")
    end
    it "returns Faraday response for url and parameters" do
      stub_alma_delete_request(url: "users/soandso/requests/12345", query: {"reason" => "REASON"})
      expect(subject.delete("/users/soandso/requests/12345", query: {"reason" => "REASON"}).class.name).to eq("Faraday::Response")
    end
  end
  context "#put(url, body)" do
    it "returns Faraday response for url and body" do
      input = "iamastring".to_json
      stub_alma_put_request(url: "users/soandso", input: input, output: "{}")
      expect(subject.put("/users/soandso", body: input).class.name).to eq("Faraday::Response")
    end
  end
  context "#get_all(url:, record_key:, limit:, query:)" do
    let(:loans0) { File.read("./spec/fixtures/jbister_loans0.json") }
    let(:loans1) { File.read("./spec/fixtures/jbister_loans1.json") }
    let(:url) { "users/jbister/loans" }
    let(:stub_loan_0) { stub_alma_get_request(query: {"limit" => 1, "offset" => 0}, output: loans0, url: url) }
    let(:stub_loan_1) { stub_alma_get_request(query: {"limit" => 1, "offset" => 1}, output: loans1, url: url) }

    it "makes multiple calls to the alma server and returns appropriate response." do
      stub_loan_0
      stub_loan_1

      response = described_class.new.get_all(url: "/#{url}", record_key: "item_loan", limit: 1)
      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.status).to eq(200)
      expect(response.body["item_loan"].count).to eq(2)
    end
    it "if alma requests fail to get everything, it tries again and if it fails again it returns an error" do
      stub1 = stub_loan_0
      stub2 = stub_alma_get_request(query: {"limit" => 1, "offset" => 1}, url: url, status: 500)
      response = described_class.new.get_all(url: "/#{url}", record_key: "item_loan", limit: 1)
      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.status).to eq(500)
      expect(response.message).to eq("Could not retrieve items.")
      expect(stub1).to have_been_requested.times(1)
      expect(stub2).to have_been_requested.times(2)
    end
    it "if alma requests fail to get everything the first time, it tries the page call again and if it succeeds returns successful full results" do
      url = "users/jbister/loans"
      stub1 = stub_loan_0
      stub2 = stub_alma_get_request(query: {"limit" => 1, "offset" => 1}, url: url, status: 500)
      stub2.then.to_return({body: loans1, status: 200, headers: {content_type: "application/json"}})

      response = described_class.new.get_all(url: "/#{url}", record_key: "item_loan", limit: 1)
      expect(stub1).to have_been_requested.times(1)
      expect(stub2).to have_been_requested.times(2)

      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.status).to eq(200)
      expect(response.body["item_loan"].count).to eq(2)
    end
  end

  context "#get_report(path:, column_names: true)" do
    let(:base_report_url) { "analytics/reports" }
    let(:path) { "/shared/University of Michigan 01UMICH_INST/Reports/fake-data" }
    let(:alma_query_params) { {"col_names" => true, "limit" => 1000, "path" => path} }

    let(:empty_circ_history) { File.read("./spec/fixtures/circ_history_empty.json") }
    let(:circ_history) { File.read("./spec/fixtures/circ_history.json") }
    let(:circ_history1) { File.read("./spec/fixtures/circ_history1.json") }
    let(:circ_history2) { File.read("./spec/fixtures/circ_history2.json") }
    it "handles empty report" do
      stub_alma_get_request(url: base_report_url, output: empty_circ_history, query: {**alma_query_params})
      response = described_class.new.get_report(path: path)
      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.status).to eq(200)
      expect(response.body.count).to eq(0)
    end

    it "returns appropriate number of Rows for a single page report" do
      stub_alma_get_request(url: base_report_url, output: circ_history, query: {**alma_query_params})
      response = described_class.new.get_report(path: path)
      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.status).to eq(200)
      expect(response.body.count).to eq(2)
    end
    it "returns the appropriate number of Rows for multipage report" do
      stub_alma_get_request(url: base_report_url, output: circ_history1, query: {**alma_query_params})
      stub_alma_get_request(url: base_report_url, output: circ_history2, query: {**alma_query_params, "token" => "fakeResumptionToken"})
      response = described_class.new.get_report(path: path)
      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.status).to eq(200)
      expect(response.body.count).to eq(3)
    end
    it "if alma requests fail to get everything on page 2+, it tries again for that page and if it fails again it returns an error" do
      stub1 = stub_alma_get_request(query: {**alma_query_params}, output: circ_history1, url: base_report_url)
      stub2 = stub_alma_get_request(url: base_report_url, query: {**alma_query_params, "token" => "fakeResumptionToken"}, status: 500)
      response = described_class.new.get_report(path: path)
      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.status).to eq(500)
      expect(response.message).to include("undefined method")
      expect(stub1).to have_been_requested.times(1)
      expect(stub2).to have_been_requested.times(2)
    end
    it "if alma requests fail to get everything on first page, it tries again and if it fails again it returns an error" do
      stub1 = stub_alma_get_request(url: base_report_url, query: {**alma_query_params}, status: 500)
      response = described_class.new.get_report(path: path)
      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.status).to eq(500)
      expect(response.message).to include("undefined method")
      expect(stub1).to have_been_requested.times(2)
    end
    it "if alma requests succeed the second time, returns the expected result" do
      stub1 = stub_alma_get_request(query: {**alma_query_params}, output: circ_history1, url: base_report_url)
      stub2 = stub_alma_get_request(url: base_report_url, query: {**alma_query_params, "token" => "fakeResumptionToken"}, status: 500).then.to_return({body: circ_history2, status: 200, headers: {content_type: "application/json"}})

      response = described_class.new.get_report(path: path)
      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.status).to eq(200)
      expect(response.body.count).to eq(3)
      expect(stub1).to have_been_requested.times(1)
      expect(stub2).to have_been_requested.times(2)
    end
    it "can take a block" do
      stub_alma_get_request(url: base_report_url, output: circ_history1, query: {**alma_query_params})
      stub_alma_get_request(url: base_report_url, output: circ_history2, query: {**alma_query_params, "token" => "fakeResumptionToken"})
      my_output = []
      response = described_class.new.get_report(path: path) { |row| my_output.push(row) }
      expect(response.status).to eq(200)
      expect(my_output.count).to eq(3)
    end
    it "works properly for a 500 error on middle page" do
      stub1 = stub_alma_get_request(url: base_report_url, output: circ_history1, query: {**alma_query_params})
      stub2 = stub_alma_get_request(url: base_report_url, query: {**alma_query_params, "token" => "fakeResumptionToken"}, status: 500)
        .then.to_return({body: circ_history1, status: 200, headers: {content_type: "application/json"}})
        .then.to_return({body: circ_history2, status: 200, headers: {content_type: "application/json"}})
      response = described_class.new.get_report(path: path)
      expect(response.class.name).to eq("AlmaRestClient::Response")
      expect(response.status).to eq(200)
      expect(response.body.count).to eq(5)
      expect(stub1).to have_been_requested.times(1)
      expect(stub2).to have_been_requested.times(3)
    end
  end
end
