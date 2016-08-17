module NotifyOn
  module Helpers
    extend ActiveSupport::Concern

    included do

      def notify_on_string_conversion(input)
        (output = input.to_s).scan(/{[\w\_]+}/).each do |match|
          output = output.gsub(/#{match}/, send(match.gsub(/[^\w\_]/, '')).to_s)
        end
        output
      end

      def notify_on_link(input)
        return notify_on_string_conversion(input) unless input.is_a?(Array)
        args = []
        input[1..-1].each do |arg|
          args << if arg == :self
            self
          else
            arg.is_a?(String) ? arg : send(arg)
          end
        end
        Rails.application.routes.url_helpers.send(input[0], *args)
      end

      def notify_on_send_email(notification, template)
        NotifyOn.configuration.mailer_class.constantize
                .notify(notification.id, template).deliver_now
      end

      def notify_on_trigger_pusher(channel, event, attrs)
        Pusher.app_id = NotifyOn.configuration.pusher_app_id
        Pusher.key    = NotifyOn.configuration.pusher_key
        Pusher.secret = NotifyOn.configuration.pusher_secret

        recipient_id = JSON.parse(attrs[:notification])["recipient_id"].to_s

        channel = notify_on_string_conversion(channel)
          .gsub(/\{:env}/, Rails.env.downcase)
          .gsub(/\{:recipient_id}/, recipient_id)
        event = notify_on_string_conversion(event)
          .gsub(/\{:env}/, Rails.env.downcase)
          .gsub(/\{:recipient_id}/, recipient_id)

        msg  = "Pusher Event: #{event} // To Channel: #{channel}\n#{attrs}"
        Rails.logger.debug(msg)

        Pusher.trigger_async(channel, event, attrs)
      end

    end

  end
end
