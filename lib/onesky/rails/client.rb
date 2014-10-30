require 'onesky'
require 'I18n'

module Onesky
  module Rails

    class Client
      attr_accessor :client, :project, :base_locale

      def initialize(api_key, api_secret, project_id)
        @client = ::Onesky::Client.new(api_key, api_secret)
        @project = @client.project(project_id.to_i)
        @base_locale = ::I18n.default_locale

        verify_config!
      end

      private

      # Verify
      # - credentials
      # - project access right
      # - correct language setting
      def verify_config!
        base_lang = ''
        response = JSON.parse(@project.list_language)
        response['data'].each do |lang|
          base_lang = lang['code'] if lang['is_base_language']
        end if response.has_key?('data') && response['data'].is_a?(Array)

        if (base_lang != @base_locale.to_s)
          raise BaseLanguageNotMatchError, "The default locale (#{@base_locale.to_s}) of your Rails app doesn't match the base language (#{base_lang}) of the OneSky project"
        end
      end
    end

    class BaseLanguageNotMatchError < StandardError; end

  end
end
