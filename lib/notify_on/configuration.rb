module NotifyOn
  class Configuration

    attr_accessor \
      :default_email,
      :default_pusher_channel,
      :default_pusher_event,
      :deliver_mail,
      :mailer_class,
      :pusher_app_id,
      :pusher_key,
      :pusher_secret

    def initialize
      @deliver_mail = :now
      @mailer_class = 'NotifyOn::NotificationMailer'
    end

  end
end
