module NotifyOn
  class NotificationMailer < ApplicationMailer

    helper 'notify_on/mailer'

    def notify(notification_id, template = 'notify', files = [])
      @notification = NotifyOn::Notification.find_by_id(notification_id)
      @recipient = @notification.recipient
      @sender = @notification.sender
      @trigger = @notification.trigger
      # Add attachments.
      files.each { |attr| attachments[attr[:name]] = attr[:file] }
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
