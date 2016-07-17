require 'spec_helper'

describe Onesky::Rails::FileClient do

  let(:config_hash) { create_config_hash }
  let(:client) {Onesky::Rails::FileClient.new(config_hash)}
  let(:sample_file_path) { File.expand_path("../../../fixtures/sample_files", __FILE__) }
  let(:file_path) { File.expand_path("../../../fixtures/locales", __FILE__) }

  before(:each) do
    stub_language_request(config_hash['api_key'], config_hash['api_secret'], config_hash['project_id'])

    # create test dir
    FileUtils.copy_entry "#{sample_file_path}/original", file_path
  end

  after(:each) do
    # delete test dir
    FileUtils.remove_dir(file_path) if File.directory?(file_path)
  end

  def create_config_hash_with_upload_options(upload_options)
    create_config_hash.tap do |config|
      config['upload'].merge!(upload_options)
    end
  end

  context '#upload' do
    before(:each) do
      stub_request(:post, full_path_with_auth_hash("/projects/#{config_hash['project_id']}/files", config_hash['api_key'], config_hash['api_secret']))
        .to_return(status: 201)
    end

    it 'all translation files to onesky' do
      expect(client.upload(file_path)).to match_array(["#{file_path}/en.yml","#{file_path}/menu.yml"])
    end

    context 'with `only` option' do
      let(:config_hash) { create_config_hash_with_upload_options('only' => 'menu.yml') }

      it 'matching translation files to onesky' do
        expect(client.upload(file_path)).to match_array(["#{file_path}/menu.yml"])
      end
    end

    context 'with `except` option' do
      let(:config_hash) { create_config_hash_with_upload_options('except' => 'menu.yml') }

      it 'matching translation files to onesky' do
        expect(client.upload(file_path)).to match_array(["#{file_path}/en.yml"])
      end
    end
  end

  context 'download' do

    let(:file_names) do
      # source filename => downloaded filename
      {
        'en.yml' => {'en' => 'en.yml', 'ja' => 'ja.yml'},
        'menu.yml' => {'en' => 'menu.yml', 'ja' => 'menu.yml'}
      }
    end

    def locale_dir(locale)
      locale == I18n.default_locale.to_s ? file_path : File.join(file_path, 'onesky_ja')
    end

    def locale_files(locale)
      Dir.glob("#{locale_dir(locale)}/*.yml")
    end

    def expected_locale_files(locale)
      ["#{locale_dir(locale)}/#{locale}.yml", "#{locale_dir(locale)}/menu.yml"]
    end

    it 'download translations from OneSky and save as YAML files' do
      locale = 'ja'
      prepare_download_requests!(locale)

      expect(locale_files(locale)).to be_empty
      client.download(file_path)
      expect(locale_files(locale)).to match_array(expected_locale_files(locale))
    end

    it 'download translations of base language from OneSky' do
      locale = 'en'
      prepare_download_requests!(locale)

      client.download(file_path, base_only: true)

      # test files created
      expected_files = expected_locale_files(locale)
      expect(locale_files(locale)).to match_array(expected_files)

      # test file content
      content = YAML.load_file(expected_files.pop)
      expected_content = YAML.load_file(File.join(sample_file_path, locale, 'menu.yml'))
      expect(content).to eq(expected_content)
    end

    it 'download all translations including base language from OneSky' do
      locales = ['en', 'ja']
      locales.each { |locale| prepare_download_requests!(locale) }

      client.download(file_path, all: true)

      locales.each do |locale|
        # test files created
        expected_files = expected_locale_files(locale)
        expect(locale_files(locale)).to match_array(expected_files)

        # test file content
        content = YAML.load_file(expected_files.pop)
        expected_content = YAML.load_file(File.join(sample_file_path, locale, "menu.yml"))
        expect(content).to eq(expected_content)
      end
    end

    context 'with `only` option' do
      let(:config_hash) { create_config_hash_with_upload_options('only' => 'menu.yml') }
      let(:expected_locale_files) { ["#{locale_dir(locale)}/menu.yml"] }
      let(:locale) { 'ja' }

      it 'downloads matching translation from OneSky and save as YAML files' do
        prepare_download_requests!(locale)
        expect(locale_files(locale)).to be_empty
        client.download(file_path)
        expect(locale_files(locale)).to match_array(expected_locale_files)
      end
    end

    context 'with `except` option' do
      let(:config_hash) { create_config_hash_with_upload_options('except' => 'menu.yml') }
      let(:expected_locale_files) { ["#{locale_dir(locale)}/ja.yml"] }
      let(:locale) { 'ja' }

      it 'downloads matching translation from OneSky and save as YAML files' do
        prepare_download_requests!(locale)
        expect(locale_files(locale)).to be_empty
        client.download(file_path)
        expect(locale_files(locale)).to match_array(expected_locale_files)
      end
    end

    def prepare_download_requests!(locale)
      Timecop.freeze
      file_names.keys.each do |file_name|
        downloaded_file_name = file_names[file_name][locale]
        response_headers = {
          'Content-Type'        => 'text/plain',
          'Content-Disposition' => "attachment; filename=#{downloaded_file_name}",
        }
        query_string = "&source_file_name=#{file_name}&locale=#{locale}"
        stub_request(:get, full_path_with_auth_hash("/projects/#{config_hash['project_id']}/translations", config_hash['api_key'], config_hash['api_secret']) + query_string)
          .to_return(
            status: 200,
            body: File.read(File.join(sample_file_path, locale, downloaded_file_name)),
            headers: response_headers)
      end
    end

  end

end
