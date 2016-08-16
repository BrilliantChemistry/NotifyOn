# Use this file to set your application's configuration for NotifyOn.
NotifyOn.configure do |config|

  # ---------------------------------------- Email
  #
  # Email messages are a common way to let a user know they have a new
  # notification. In some cases, you want that notification to come from another
  # user. Other times, your system may handle it. Defining a default email
  # address means that if you don't specify "to" when calling "notify_on", the
  # default email address will be used.
  #
  # config.default_email = 'No Reply <noreply@yourdomain.com>'
  #
  # You can also override the notification mailer class if you need to add
  # custom functionality not supported in NotifyOn's NotificationMailer class.
  #
  # config.mailer_class = 'NotifyOn::NotificationMailer'

  # ---------------------------------------- Pusher
  #
  # Pusher enables you to send notifications in real-time. Learn more about
  # Pusher at https://pusher.com. If you are going to use pusher, the following
  # values are required:
  #
  # config.pusher_app_id = 'my_app_id'
  # config.pusher_key = 'my_key'
  # config.pusher_secret = 'my_secret'
  #
  # Note: You will likely want these values dependent on your environment. You
  # can use a conditional clause here, or you may set these values instead in
  # your specific environment configuration files. Here's an example:
  #
  # if Rails.env.production?
  #   config.pusher_app_id = 'my_app_id'
  #   config.pusher_key = 'my_key'
  #   config.pusher_secret = 'my_secret'
  # else
  #   config.pusher_app_id = 'my_app_id'
  #   config.pusher_key = 'my_key'
  #   config.pusher_secret = 'my_secret'
  # end

end
