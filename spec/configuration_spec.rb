RSpec.describe AlmaRestClient, "#configuration" do
  after(:each) do
    AlmaRestClient.set_default_config
  end
  subject do
    AlmaRestClient.configuration
  end
  context "alma_api_key" do
    it "can be set to something else" do
      AlmaRestClient.configure { |config| config.alma_api_key = "my_api_key" }
      expect(subject.alma_api_key).to eq("my_api_key")
    end
    it "defaults to ALMA_API_KEY env_var" do
      expect(subject.alma_api_key).to eq(ENV.fetch("ALMA_API_KEY"))
    end
    it "defaults to empty string when ALMA_API_KEY env var is not defined" do
      with_modified_env ALMA_API_KEY: nil do
        AlmaRestClient.set_default_config
        expect(subject.alma_api_key).to eq("")
      end
    end
  end
  context "alma_api_host" do
    it "can be set to something else" do
      AlmaRestClient.configure { |config| config.alma_api_host = "my_api_host" }
      expect(subject.alma_api_host).to eq("my_api_host")
    end
    it "defaults to ALMA_API_KEY env_var" do
      with_modified_env ALMA_API_HOST: "alma_api_host_env_var" do
        AlmaRestClient.set_default_config
        expect(subject.alma_api_host).to eq("alma_api_host_env_var")
      end
    end
    it "defaults to North America url string when ALMA_API_HOST env var is not defined" do
      with_modified_env ALMA_API_HOST: nil do
        AlmaRestClient.set_default_config
        expect(subject.alma_api_host).to eq("https://api-na.hosted.exlibrisgroup.com")
      end
    end
  end
  context "http_adapter" do
    it "can be set to something else" do
      AlmaRestClient.configure { |config| config.http_adapter = :my_http_adapter }
      expect(subject.http_adapter).to eq(:my_http_adapter)
    end
    it "has httpx as the default adapter" do
      expect(subject.http_adapter).to eq(:httpx)
    end
  end
  context "retry_options" do
    it "can be set to something else" do
      AlmaRestClient.configure { |config| config.retry_options = {thing: "stuff"} }
      expect(subject.retry_options).to eq({thing: "stuff"})
    end
    it "has max 1 and retry_statuses: [500] as the default settings" do
      expect(subject.retry_options).to eq({max: 1, retry_statuses: [500]})
    end
    it "can remove and change default settings" do
      AlmaRestClient.configure do |config|
        config.retry_options.delete(:max)
        config.retry_options[:retry_statuses] = [200]
      end
      expect(subject.retry_options).to eq({retry_statuses: [200]})
    end
  end
end
