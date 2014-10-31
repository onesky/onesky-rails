require 'spec_helper'

describe Onesky::Rails::Client do

  describe '#new' do

    it 'with correct config' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{config_hash['project_id']}/languages", config_hash['api_key'], config_hash['api_secret']))
        .to_return(status: 200, body: languages_response.to_json)

      client = Onesky::Rails::Client.new(config_hash)
      expect(client.base_locale).to eq(I18n.default_locale)
    end

    it 'with invalid config' do
      expect{Onesky::Rails::Client.new({})}.to raise_error(ArgumentError)
    end

    it 'save locale of languages activated at OneSky' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{config_hash['project_id']}/languages", config_hash['api_key'], config_hash['api_secret']))
        .to_return(status: 200, body: languages_response.to_json)

      client = Onesky::Rails::Client.new(config_hash)
      expect(client.onesky_locales).to eq(['ja'])
    end

    it 'with incorrect credentials' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{config_hash['project_id']}/languages", config_hash['api_key'], config_hash['api_secret']))
        .to_return(status: 401, body: {meta: {code: 401, message: 'Fail to authorize'}}.to_json)

      expect {Onesky::Rails::Client.new(config_hash)}.to raise_error(Onesky::Errors::UnauthorizedError, '401 Unauthorized - Fail to authorize')
    end

    it 'with incorrect project ID' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{config_hash['project_id']}/languages", config_hash['api_key'], config_hash['api_secret']))
        .to_return(status: 403, body: {meta: {code: 403, message: 'No right to access project'}}.to_json)

      expect {Onesky::Rails::Client.new(config_hash)}.to raise_error(Onesky::Errors::ForbiddenError, '403 Forbidden - No right to access project')
    end

    it 'with mis-match locale' do
      I18n.default_locale = :ja

      stub_request(:get, full_path_with_auth_hash("/projects/#{config_hash['project_id']}/languages", config_hash['api_key'], config_hash['api_secret']))
        .to_return(status: 200, body: languages_response.to_json)

      expect {Onesky::Rails::Client.new(config_hash)}.to raise_error(Onesky::Rails::BaseLanguageNotMatchError, 'The default locale (ja) of your Rails app doesn\'t match the base language (en) of the OneSky project')
    end
  end

end
