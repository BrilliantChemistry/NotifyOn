module NotifyOn
  class NotificationMailer < ApplicationMailer

    def notify(notification_id, template = 'notify')
      @notification = NotifyOn::Notification.find_by_id(notification_id)
      @recipient = @notification.recipient
      @sender = @notification.sender
      @trigger = @notification.trigger
      # Save a reference to the message if requested.
      if @notification.should_save_email_id?
        headers['message-id'] = (message_id = SecureRandom.uuid)
        @trigger.update_columns(:message_id => message_id)
      end
      mail :to => @recipient.email,
           :from => @notification.email_from,
           :subject => @notification.email_subject,
           :template_path => 'notifications',
           :template_name => template
    end

  end
end
