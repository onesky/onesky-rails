require 'onesky'

module Onesky
  module Rails

    class Client
      attr_accessor :client, :project, :base_locale, :onesky_locales

      def initialize(api_key, api_secret, project_id)
        @client = ::Onesky::Client.new(api_key, api_secret)
        @project = @client.project(project_id.to_i)
        @base_locale = ::I18n.default_locale
        @onesky_locales = []

        save_locales(get_languages_and_verify_config!)
      end

      private

      # Verify credentials and project access right
      # by initial a request to retrieve languages
      # @return  Array  Languages response from OneSky
      def get_languages_and_verify_config!
        JSON.parse(@project.list_language)['data']
      end

      def save_locales(languages)
        languages.each do |lang|
          locale = lang['code'].gsub('-', '_')
          if lang['is_base_language']
            verify_base_locale!(locale)
          else
            @onesky_locales << locale
          end
        end
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
