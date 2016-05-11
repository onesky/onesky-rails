require 'spec_helper'

describe Onesky::Rails::FileClient do

  let(:config_hash) { create_config_hash }
  let(:client) {Onesky::Rails::FileClient.new(config_hash)}
  let(:sample_file_path) { File.expand_path("../../../fixtures/sample_files", __FILE__) }
  let(:file_path) { File.expand_path("../../../fixtures/locales", __FILE__) }

  before(:each) do
    stub_language_request(config_hash['api_key'], config_hash['api_secret'], config_hash['project_id'])

    # create test dir
    FileUtils.copy_entry "#{sample_file_path}/en", file_path
  end

  after(:each) do
    # delete test dir
    FileUtils.remove_dir(file_path) if File.directory?(file_path)
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

    it 'download translations from OneSky and save as YAML files' do
      prepare_download_requests!('ja')

      expect(locale_files).to be_empty
      client.download(file_path)
      expect(locale_files).to match_array(expected_locale_files)
    end

    def prepare_download_requests!(locale)
      Timecop.freeze
      file_names.each do |file_name|
        response_headers = {
          'Content-Type'        => 'text/plain',
          'Content-Disposition' => "attachment; filename=#{file_name}",
        }
        query_string = "&source_file_name=#{file_name}&locale=#{locale}"
        stub_request(:get, full_path_with_auth_hash("/projects/#{config_hash['project_id']}/translations", config_hash['api_key'], config_hash['api_secret']) + query_string)
          .to_return(
            status: 200,
            body: File.read(File.join(sample_file_path, 'ja', file_name.sub(/en/, 'ja'))),
            headers: response_headers)
      end
    end

  end

end
