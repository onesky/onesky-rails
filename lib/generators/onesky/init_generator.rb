module Onesky
  module Generators
    class InitGenerator < ::Rails::Generators::Base

      desc "Generate config file for onesky-rails gem."

      argument :api_key,     :type => :string,  :desc => "API Key"
      argument :api_secret,  :type => :string,  :desc => "API Secret"
      argument :project_id,  :type => :string,  :desc => "Project ID"

      class_option :force,   :type => :boolean, :default => false, :desc => "Overwrite if config file already exists"

      CONFIG_PATH = File.join(::Rails.root.to_s, 'config', 'onesky.yml')

      def remove_config_file
        if File.exists? CONFIG_PATH
          if options.force?
            say_status("warning", "Overwrite existing config file.", :yellow)
            remove_file CONFIG_PATH
          else
            say_status("error", "Please use --force to overwrite existing config file.", :red)
          end
        end
      end

      source_root File.expand_path("../../templates", __FILE__)

      def create_config_file
        # create_file(CONFIG_PATH, YAML_COMMENT + config_hash.to_yaml)
        template "onesky.yml.tt", "config/onesky.yml"
      end

      private

      def config_hash
        {api_key: api_key, api_secret: api_secret, project_id: project_id.to_i}
      end
    end
  end
end
