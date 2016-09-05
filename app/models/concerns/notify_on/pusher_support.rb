module NotifyOn
  module PusherSupport
    extend ActiveSupport::Concern

    def push!
      return false unless can_push?

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
      return nil unless can_push?
      channel = options[:pusher][:channel] if options[:pusher].respond_to?(:[])
      channel = NotifyOn.configuration.default_pusher_channel if channel.blank?
      @pusher_channel_name ||= convert_string(channel)
    end

    def pusher_event_name
      return nil unless can_push?
      event = options[:pusher][:event] if options[:pusher].respond_to?(:[])
      event = NotifyOn.configuration.default_pusher_event if event.blank?
      @pusher_event_name ||= convert_string(event)
    end

    def pusher_attrs
      return nil unless can_push?
      {
        :notification => self.to_json,
        :trigger => trigger.to_json,
        :data => (options[:pusher][:data] if options[:pusher].respond_to?(:[]))
      }
    end

    private

      def pusher_config
        Pusher.app_id = NotifyOn.configuration.pusher_app_id
        Pusher.key    = NotifyOn.configuration.pusher_key
        Pusher.secret = NotifyOn.configuration.pusher_secret
      end

      def can_push?
        options[:pusher].present? ||
        (options[:pusher].nil? && NotifyOn.configuration.use_pusher_by_default)
      end

  end
end
