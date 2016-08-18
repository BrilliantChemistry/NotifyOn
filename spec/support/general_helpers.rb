module GeneralHelpers

  def notification_count
    NotifyOn::Notification.count
  end

  def first_notification
    NotifyOn::Notification.first
  end

  def total_emails
    ActionMailer::Base.deliveries.count
  end

  def emails
    ActionMailer::Base.deliveries
  end

end
