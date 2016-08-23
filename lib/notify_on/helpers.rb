module NotifyOn
  module Helpers
    extend ActiveSupport::Concern

    private

      def create_notify_on_notifications(options)

        # skip_notifications disables all notifications for an instance.
        return if skip_notifications == true

        # skip_if is an option passed via notify_on that can conditionally
        # disable notifications for an instance.
        return if options[:skip_if].present? && send(options[:skip_if]) == true

        # Collect notifications so we can return the set if we are creating more
        # than one (when "to" is an array or collection).
        notifications = []

        # "to" must be a method or attribute, and here we resolve it.
        to = send(options[:to].to_s)

        # Ensure "to" is an array so we can iterate over it, even if that's only
        # happening once.
        (to.is_a?(Array) ? to : [to]).each do |recipient|

          # Notification is created with the basic information. Much of the
          # advanced work happens within the model, which is why we store
          # "options" in the record.
          notification = NotifyOn::Notification.create!(
            :recipient => recipient,
            :sender => options[:from].blank? ? nil : send(options[:from].to_s),
            :trigger => self,
            :description_raw => options[:message],
            :link_raw => options[:link],
            :options => options
          )

          # Attempt to send the notification via Pusher, if requested.
          # -- NotifyOn::PusherSupport
          notification.push! if options[:pusher].present?

          # Send the notification via email, if requested.
          # -- NotifyOn::EmailSupport
          notification.send_email! if options[:email].present?

          # Add notification to the collection for response.
          notifications << notification
        end

        # Return the collection of notifications that we created.
        notifications
      end

  end
end
