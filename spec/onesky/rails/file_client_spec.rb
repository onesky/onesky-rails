require 'spec_helper'

describe Onesky::Rails::FileClient do

  let(:config_hash) { create_config_hash }
  let(:client) {Onesky::Rails::FileClient.new(config_hash)}
  let(:file_path) { File.expand_path("../../../fixtures/locales", __FILE__) }

  before(:each) do
    stub_language_request(config_hash['api_key'], config_hash['api_secret'], config_hash['project_id'])
  end

  context '#upload' do
    it 'all translation files to onesky' do
      stub_request(:post, full_path_with_auth_hash("/projects/#{config_hash['project_id']}/files", config_hash['api_key'], config_hash['api_secret']))
        .to_return(status: 201)

      expect(client.upload(file_path)).to match_array(["#{file_path}/en.yml","#{file_path}/special_en.yml"])
    end
  end

  context 'download' do

    let(:expected_locale_files) do
      ["#{locale_dir}/ja.yml", "#{locale_dir}/special_ja.yml"]
    end

    let(:file_names) {['en.yml', 'special_en.yml']}

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
      prepare_download_requests!

      expect(locale_files).to be_empty
      client.download(file_path)
      expect(locale_files).to match_array(expected_locale_files)
    end

    def prepare_download_requests!
      Timecop.freeze
      file_names.each do |file_name|
        response_headers = {
          'Content-Type'        => 'text/plain',
          'Content-Disposition' => "attachment; filename=#{file_name}",
        }
        query_string = "&source_file_name=#{file_name}&locale=ja"
        stub_request(:get, full_path_with_auth_hash("/projects/#{config_hash['project_id']}/translations", config_hash['api_key'], config_hash['api_secret']) + query_string)
          .to_return(
            status: 200,
            body: File.read(File.join(file_path, file_name)),
            headers: response_headers)
      end
    end

  end

end
