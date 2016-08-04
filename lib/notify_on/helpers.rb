module NotifyOn
  module Helpers
    extend ActiveSupport::Concern

    included do

      def notify_on_description(input)
        (output = input.to_s).scan(/{[\w\_]+}/).each do |match|
          output = output.gsub(/#{match}/, send(match.gsub(/[^\w\_]/, '')))
        end
        output
      end

      def notify_on_link(input)
        return input unless input.is_a?(Array)
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
        NotifyOn::NotificationMailer.notify(notification.id, template).deliver
      end

    end

  end
end
