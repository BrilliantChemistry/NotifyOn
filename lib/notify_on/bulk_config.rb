require 'yaml'

module NotifyOn
  class BulkConfig

    def initialize(options = {})
    end

    def self.load
      new.load
    end

    def load
      return unless File.exists?(config_file) && config
      config.each do |model_name, notification_name|
        notification_name.each do |name, notify_on_config|
          model_name.classify.constantize.class_eval do
            notify_on notify_on_config['action'],
                      notify_on_config.symbolize_keys
          end
        end
      end
    end

    private

      def config_file
        Rails.root.join('config', 'notifications.yml').to_s
      end

      def config
        YAML.load_file(config_file)
      end

  end
end
