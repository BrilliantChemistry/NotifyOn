# Use this file to set your application's configuration for NotifyOn.
NotifyOn.configure do |config|

  # ---------------------------------------- Email

  # Email messages are a common way to let a user know they have a new
  # notification. In some cases, you want that notification to come from another
  # user. Other times, your system may handle it. Defining a default email
  # address means that if you don't specify "to" when calling "notify_on", the
  # default email address will be used.
  #
  # config.default_email = 'No Reply <noreply@yourdomain.com>'
  #
  # Note: You can use NotifyOn's string interpolation here. It will first
  # attempt methods on the trigger, and then fallback to the notification.
  # Therefore, you have access to the "sender" object, and could choose to
  # default to the sender's email address, like so:
  #
  # config.default_email = '{sender.name} <{sender.email}>'
  #
  # You can also override the notification mailer class if you need to add
  # custom functionality not supported in NotifyOn's NotificationMailer class.
  #
  # config.mailer_class = 'NotifyOn::NotificationMailer'
  #
  # NotifyOn's email notification service provides the option to use Active Job
  # to send email messages in the background instead of during the request. If
  # you enable Active Job, NotifyOn will use your application settings for
  # Active Job. Learn more at
  # http://guides.rubyonrails.org/active_job_basics.html
  #
  # config.deliver_mail = :now # or :later

  # ---------------------------------------- Pusher

  # Pusher enables you to send notifications in real-time. Learn more about
  # Pusher at https://pusher.com. If you are going to use Pusher, you need to
  # include the following values:
  #
  # config.pusher_app_id = 'my_app_id'
  # config.pusher_key = 'my_key'
  # config.pusher_secret = 'my_secret'
  #
  # Note: You may want to use environment-dependent values, not tracked by git,
  # so your secrets are not exposed. You may choose to use Rails' secrets for
  # this. For example:
  #
  # config.pusher_app_id = Rails.application.secrets.pusher_app_id
  # config.pusher_key = Rails.application.secrets.pusher_key
  # config.pusher_secret = Rails.application.secrets.pusher_secret
  #
  # While you can configure your Pusher event in each "notify_on" call, you can
  # also set your default configuration so you don't have to restate it for
  # every notification.
  #
  # config.default_pusher_channel = 'presence_{:env}_notification_{:recipient_id}'
  # config.default_pusher_event = 'new_notification'

end
