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

      def verify_languages!
        languages = get_languages_from_onesky!
        languages.each do |language|
          locale = to_rails_locale(language['code'])
          if (language['is_base_language'])
            verify_base_locale!(locale)
          else
            @onesky_locales << locale
          end
        end
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
