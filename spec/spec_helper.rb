require 'digest'
require 'webmock/rspec'
require 'i18n'
require 'onesky/rails'
require 'onesky'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:all) do
    I18n.enforce_available_locales = false
    I18n.default_locale = :en # reset to default locale
  end

  config.after(:all) do
    I18n.default_locale = :en # reset to default locale
  end
end

def auth_query_string(api_key, api_secret)
  now = Time.now.to_i
  output = '?'
  output += "api_key=#{api_key}"
  output += "&timestamp=#{now.to_s}"
  output += "&dev_hash=#{Digest::MD5.hexdigest(now.to_s + api_secret)}"

  output
end

def full_path_with_auth_hash(path, api_key, api_secret)
  "#{Helpers::Request::ENDPOINT}/#{Helpers::Request::VERSION}#{path}#{auth_query_string(api_key, api_secret)}"
end

def stub_language_request(api_key, api_secret, project_id)
  stub_request(:get, full_path_with_auth_hash("/projects/#{project_id}/languages", api_key, api_secret))
    .to_return(status: 200, body: languages_response.to_json)
end

def languages_response
  {data: 
    [
      {code: 'en', is_base_language: true},
      {code: 'ja', is_base_language: false},
      {code: 'zh-TW', is_base_language: false}
    ]
  }
end
