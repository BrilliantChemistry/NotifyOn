class NotificationMailer < NotifyOn::NotificationMailer

  def notify(notification_id, template = 'notify')
    @notification = NotifyOn::Notification.find_by_id(notification_id)
    @recipient = @notification.recipient
    @sender = @notification.sender
    @trigger = @notification.trigger
    mail :to => @recipient.email,
         :from => 'Bob Ross <admin@bobross.com>',
         :subject => @notification.description,
         :template_path => 'notifications',
         :template_name => template
  end

end
