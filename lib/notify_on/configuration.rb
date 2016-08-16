module NotifyOn
  class Configuration

    attr_accessor :default_email, :mailer_class, :pusher_app_id, :pusher_key,
                  :pusher_secret

    def initialize
      @mailer_class = 'NotifyOn::NotificationMailer'
    end

  end
end
