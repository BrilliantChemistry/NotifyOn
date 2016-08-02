module NotifyOn
  class NotificationMailer < ApplicationMailer

    def notify(notification_id, template = 'notify')
      @notification = NotifyOn::Notification.find_by_id(notification_id)
      @recipient = @notification.recipient
      mail :to => @recipient.email,
           :from => @notification.sender.email,
           :subject => @notification.description,
           :template_path => 'notifications',
           :template_name => template
    end

  end
end
