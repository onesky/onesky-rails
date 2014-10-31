require 'onesky/rails/client'
require 'yaml'

module Onesky
  module Rails

    class FileClient < Onesky::Rails::Client

      FILE_FORMAT = 'RUBY_YAML'
      ENCODING    = 'UTF-8'
      DIR_PREFIX  = 'onesky_'

      def upload(string_path)
        get_default_locale_files(string_path).map do |path|
          filename = File.basename(path)
          puts "Uploading #{filename}"
          @project.upload_file(file: path, file_format: FILE_FORMAT)
          path
        end
      end

      def download(string_path)
        files = get_default_locale_files(string_path).map {|path| File.basename(path)}

        @onesky_locales.each do |locale|
          puts "#{locale_dir(locale)}/"
          onesky_locale = locale.gsub('_', '-')
          files.each do |file|
            response = @project.export_translation(source_file_name: file, locale: onesky_locale)
            if response.code == 200
              saved_file = save_translation(response, string_path, locale, file)
              puts "  #{saved_file}"
            end
          end
        end
      end

      protected

      def locale_dir(locale)
        DIR_PREFIX + locale
      end

      def extract_file_name(header_hash)
        search_text = 'filename='
        if disposition = header_hash[:content_disposition]
          if idx = disposition.index(search_text)
            disposition[(idx + search_text.length)..-1]
          end
        end
      end

      def make_translation_dir(dir_path, locale)
        target_path = File.join(dir_path, locale_dir(locale))
        Dir.mkdir(target_path) unless File.directory?(target_path)
        target_path
      end

      def get_default_locale_files(string_path)
        Dir.glob("#{string_path}/**/*.yml").map do |path|
          content_hash = YAML.load_file(path)
          path if content_hash && content_hash.has_key?(@base_locale.to_s)
        end.compact
      end

      def save_translation(response, string_path, locale, file)
        locale_path = make_translation_dir(string_path, locale)
        target_file = extract_file_name(response.headers) || file
        File.open(File.join(locale_path, target_file), 'w') do |f|
          f.write(response.body.force_encoding(ENCODING))
        end
        target_file
      end

    end

  end
end
