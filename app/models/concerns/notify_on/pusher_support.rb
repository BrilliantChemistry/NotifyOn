module NotifyOn
  module PusherSupport
    extend ActiveSupport::Concern

    def push!
      return false unless options[:pusher].present?

      pusher_config

      msg  = "Pusher Event: #{pusher_event_name} | "
      msg += "To Channel: #{pusher_channel_name}\n#{pusher_attrs}"
      Rails.logger.debug(msg)

      Pusher.trigger_async(pusher_channel_name, pusher_event_name, pusher_attrs)
    end

    def pusher_sender_active?
      ids = Pusher.channel_users(pusher_channel_name)[:users]
                  .collect { |u| u["id"].to_i }
      ids.include?(sender_id)
    end

    def pusher_recipient_active?
      ids = Pusher.channel_users(pusher_channel_name)[:users]
                  .collect { |u| u["id"].to_i }
      ids.include?(recipient_id)
    end

    def pusher_channel_name
      return nil unless options[:pusher] && options[:pusher][:channel]
      @pusher_channel_name ||= convert_string(options[:pusher][:channel])
    end

    def pusher_event_name
      return nil unless options[:pusher] && options[:pusher][:event]
      @pusher_event_name ||= convert_string(options[:pusher][:event])
    end

    def pusher_attrs
      return nil unless options[:pusher]
      {
        :notification => self.to_json,
        :trigger => trigger.to_json,
        :data => options[:pusher][:data]
      }
    end

    private

      def pusher_config
        Pusher.app_id = NotifyOn.configuration.pusher_app_id
        Pusher.key    = NotifyOn.configuration.pusher_key
        Pusher.secret = NotifyOn.configuration.pusher_secret
      end

  end
end
