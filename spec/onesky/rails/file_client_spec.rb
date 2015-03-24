require 'spec_helper'

describe Onesky::Rails::FileClient do

  let(:config_hash) { create_config_hash }
  let(:client) {Onesky::Rails::FileClient.new(config_hash)}
  let(:file_path) { File.expand_path("../../../fixtures/locales", __FILE__) }

  before(:each) do
    stub_language_request(config_hash['api_key'], config_hash['api_secret'], config_hash['project_id'])
  end

  context '#upload' do
    it 'strings to onesky' do
      stub_request(:post, full_path_with_auth_hash("/projects/#{config_hash['project_id']}/files", config_hash['api_key'], config_hash['api_secret']))
        .to_return(status: 201)

      expect(client.upload(file_path)).to eq(["#{file_path}/en.yml"])
    end
  end

  context 'download' do

    let(:file_name) {'ja.yml'}
    let(:response_headers) do
      {
        'Content-Type'        => 'text/plain',
        'Content-Disposition' => "attachment; filename=#{file_name}",
      }
    end
    let(:query_string) {'&source_file_name=en.yml&locale=ja'}

    def locale_dir
      File.join(file_path, 'onesky_ja')
    end

    def locale_files
      Dir.glob("#{locale_dir}/*.yml")
    end

    def delete_test_dir
      if File.directory?(locale_dir)
        File.delete(*Dir.glob("#{locale_dir}/**/*"))
        Dir.delete(locale_dir)
      end
    end

    before(:each) do
      delete_test_dir
    end

    after(:each) do
      delete_test_dir
    end

    it 'download translations from OneSky and save as YAML files' do
      stub_request(:get, full_path_with_auth_hash("/projects/#{config_hash['project_id']}/translations", config_hash['api_key'], config_hash['api_secret']) + query_string)
        .to_return(
          status: 200,
          body: File.read(File.join(file_path, file_name)),
          headers: response_headers)

      expect(locale_files).to be_empty
      client.download(file_path)
      expect(locale_files).to eq(["#{locale_dir}/#{file_name}"])
    end
  end

end
