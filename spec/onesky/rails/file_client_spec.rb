require 'spec_helper'

describe Onesky::Rails::FileClient do

  let(:api_key) {'fakeapi'}
  let(:api_secret) {'fakesecret'}
  let(:project_id) {99}
  let(:client) {Onesky::Rails::FileClient.new(api_key, api_secret, project_id)}
  let(:file_path) { File.expand_path("../../../fixtures/locales", __FILE__) }

  before(:each) do
    stub_language_request(api_key, api_secret, project_id)
  end

  context '#upload' do
    it "uploads base locale YAML files" do
      stub_request(:post, full_path_with_auth_hash("/projects/#{project_id}/files", api_key, api_secret))
        .to_return(status: 201)

      
      expect(client.upload(file_path)).to eq(["#{file_path}/en.yml"])
    end
  end

  context 'download' do
  end

end
