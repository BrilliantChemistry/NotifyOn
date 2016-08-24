module NotifyOn
  class NotificationMailer < ApplicationMailer

    def notify(notification_id, template = 'notify')
      @notification = NotifyOn::Notification.find_by_id(notification_id)
      @recipient = @notification.recipient
      @sender = @notification.sender
      @trigger = @notification.trigger
      mail :to => @recipient.email,
           :from => @notification.email_from,
           :subject => @notification.email_subject,
           :template_path => 'notifications',
           :template_name => template
    end

  end
end
