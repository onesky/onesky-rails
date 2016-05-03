require 'onesky'

module Onesky
  module Rails

    class Client
      attr_accessor :client, :project, :base_locale, :onesky_locales, :config

      def initialize(config_hash)
        unless is_valid_config! config_hash
          raise ArgumentError, 'Invalid config. Please check if `api_key`, `api_secret` and `project_id` exist.'
        end

        @config = config_hash
        @client = ::Onesky::Client.new(@config['api_key'], @config['api_secret'])
        @client.plugin_code = 'rails-string'
        @project = @client.project(@config['project_id'].to_i)
        @base_locale = config_hash.fetch('base_locale', ::I18n.default_locale)
        @onesky_locales = []
      end

      def verify_languages!(options = {})
        languages = get_languages_from_onesky!
        languages.each do |language|
          locale = language['custom_locale'] || to_rails_locale(language['code'])

          verify_base_locale!(locale) if language['is_base_language']

          @onesky_locales << locale if allowed_for?(language, options)
        end
      end

      #
      # Determine if a language will be used to be downloaded or not.
      #
      # With options[:all] == true, all the languages will be used.
      # With options[:base_only] == true, only the base language of the project
      # will be used to download tranlsation file.
      # Otherwise, this method will allow only other languages than the base
      # language.
      #
      def allowed_for?(language, options)
        return true if options[:all] == true
        return true if language['is_base_language'] && options[:base_only] == true
        language['is_base_language'] == false && options[:base_only] == false
      end

      def to_onesky_locale(locale)
        locale.gsub('_', '-')
      end

      def to_rails_locale(locale)
        locale.gsub('-', '_')
      end

      private

      def is_valid_config!(config)
        config.has_key?('api_key') && config.has_key?('api_secret') && config.has_key?('project_id')
      end

      def get_languages_from_onesky!
        JSON.parse(@project.list_language)['data']
      end

      def verify_base_locale!(locale)
        if (locale != @base_locale.to_s)
          raise BaseLanguageNotMatchError, "The default locale (#{@base_locale.to_s}) of your Rails app doesn't match the base language (#{locale}) of the OneSky project"
        end
      end
    end

    class BaseLanguageNotMatchError < StandardError; end

  end
end
