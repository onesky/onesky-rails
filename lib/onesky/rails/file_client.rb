require 'onesky/rails/client'
require 'yaml'

module Onesky
  module Rails

    class FileClient < Onesky::Rails::Client

      FILE_FORMAT = 'RUBY_YAML'

      def upload(string_path)
        get_default_locale_files(string_path).map do |path|
          filename = path.sub(string_path, '')
          puts "Uploading #{filename}"
          @project.upload_file(file: path, file_format: FILE_FORMAT)
          path
        end
      end

      protected

      def get_default_locale_files(string_path)
        Dir.glob("#{string_path}/**/*.yml").map do |path|
          content_hash = YAML.load_file(path)
          path if content_hash.has_key?(@base_locale.to_s)
        end.compact
      end

    end

  end
end
