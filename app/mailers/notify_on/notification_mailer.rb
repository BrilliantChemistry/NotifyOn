module NotifyOn
  class NotificationMailer < ApplicationMailer

    def notify(notification_id)
      @notification = NotifyOn::Notification.find_by_id(notification_id)
      @recipient = @notification.recipient
      mail :to => @recipient.email, :from => @notification.sender.email,
           :subject => @notification.description
    end

  end
end
