module NotifyOn
  module EmailSupport
    extend ActiveSupport::Concern

    included do
      before_save :set_default_from
    end

    def send_email!
      return false unless options[:email] && can_send_email?
      NotifyOn.configuration.mailer_class.constantize.notify(id, email_template)
              .deliver_now
    end

    def can_send_email?
      return false unless options[:email]
      return true unless options[:email][:send_unless]
      begin
        !trigger.send(options[:email][:send_unless].to_s)
      rescue
        !send(options[:email][:send_unless].to_s)
      end
    end

    private

      def email_template
        return false unless options[:email]
        @email_template ||= options[:email][:template]
      end

      def set_default_from
        return if options[:email].blank? || use_default_email?
        self.use_default_email = options[:email][:default_from] || false
        return
      end

  end
end
