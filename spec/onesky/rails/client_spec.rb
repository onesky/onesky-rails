require 'spec_helper'

describe Onesky::Rails::Client do

  let(:api_key) {'fakeapi'}
  let(:api_secret) {'fakesecret'}
  let(:project_id) {99}

  let(:success_response) {languages_response}

  describe 'verify config' do

    it 'with correct config' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/languages", api_key, api_secret))
        .to_return(status: 200, body: success_response.to_json)

      client = Onesky::Rails::Client.new(api_key, api_secret, project_id)
      expect(client.base_locale).to eq(I18n.default_locale)
    end

    it 'save locale of languages activated at OneSky' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/languages", api_key, api_secret))
        .to_return(status: 200, body: success_response.to_json)

      client = Onesky::Rails::Client.new(api_key, api_secret, project_id)
      expect(client.onesky_locales).to eq(['ja', 'zh_TW'])
    end

    it 'with incorrect credentials' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/languages", api_key, api_secret))
        .to_return(status: 401, body: {meta: {code: 401, message: 'Fail to authorize'}}.to_json)

      expect {Onesky::Rails::Client.new(api_key, api_secret, project_id)}.to raise_error(Onesky::Errors::UnauthorizedError, '401 Unauthorized - Fail to authorize')
    end

    it 'with incorrect project ID' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/languages", api_key, api_secret))
        .to_return(status: 403, body: {meta: {code: 403, message: 'No right to access project'}}.to_json)

      expect {Onesky::Rails::Client.new(api_key, api_secret, project_id)}.to raise_error(Onesky::Errors::ForbiddenError, '403 Forbidden - No right to access project')
    end

    it 'with mis-match locale' do
      I18n.default_locale = :ja

      stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/languages", api_key, api_secret))
        .to_return(status: 200, body: success_response.to_json)

      expect {Onesky::Rails::Client.new(api_key, api_secret, project_id)}.to raise_error(Onesky::Rails::BaseLanguageNotMatchError, 'The default locale (ja) of your Rails app doesn\'t match the base language (en) of the OneSky project')
    end
  end

end
