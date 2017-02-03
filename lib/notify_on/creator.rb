module NotifyOn
  module Creator

    private

      def create_notify_on_notifications(options)

        # skip_notifications disables all notifications for an instance.
        return if skip_notifications == true

        # Collect notifications so we can return the set if we are creating more
        # than one (when "to" is an array or collection).
        notifications = []

        # "to" must be a method or attribute, and here we resolve it.
        to = options[:to].to_s == 'self' ? self : send(options[:to].to_s)

        # We don't need a sender all the time, but we figure out who it is now
        # so we can more easily work with the object.
        sender = options[:from].blank? ? nil : send(options[:from].to_s)

        # Ensure "to" is an array so we can iterate over it, even if that's only
        # happening once.
        (to.respond_to?(:each) ? to : [to]).each do |recipient|

          # If we have an update strategy, then we first need to look for an
          # exiting notification.
          notification = find_from_update_strategy(recipient, sender, options)

          # Create a new notification if we didn't have an update strategy or
          # couldn't find one. Much of the advanced work happens within the
          # model, which is why we store "options" in the record.
          notification = NotifyOn::Notification.new(
            :recipient => recipient,
            :sender => sender,
            :description_raw => options[:message],
            :options => options
          ) if notification.nil?

          # Update the shared attributes regardless of whether the notification
          # is being created or updated.
          notification.assign_attributes(
            :unread => true,
            :trigger => self,
            :link_raw => options[:link]
          )

          # Make sure we can save the notification.
          notification.save!

          # Attempt to send the notification via Pusher. There are catches in
          # place to prevent it from being pushed if disabled.
          # -- NotifyOn::PusherSupport
          notification.push!

          # Send the notification via email, if requested.
          # -- NotifyOn::EmailSupport
          notification.send_email! if options[:email].present?

          # Add notification to the collection for response.
          notifications << notification
        end

        # Return the collection of notifications that we created.
        notifications
      end

      def find_from_update_strategy(to, from, options)
        # Exit if we don't have a strategy, and currently we only support the
        # :sender strategy.
        return nil unless options[:update] && options[:update][:strategy] &&
                          options[:update][:strategy] == :sender &&
                          from.present?
        if (scope = options[:update][:scope]).present?
          to.notifications.from_with_type(from, self.class.name).recent
            .includes(:trigger => [scope])
            .select{ |n| n.trigger.send(scope) == self.send(scope)}[0]
        else
          to.notifications.from_with_type(from, self.class.name).recent
            .limit(1)[0]
        end
      end

  end
end
