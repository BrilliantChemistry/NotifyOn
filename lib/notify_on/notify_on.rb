class << ActiveRecord::Base

  def notify_on(action, options = {})

    case action.to_sym
    when :create

      after_create :"notify_#{options[:to]}_on_create"

      define_method "notify_#{options[:to]}_on_create" do
        (desc = options[:message].to_s).scan(/{[\w\_]+}/).each do |match|
          desc = desc.gsub(/#{match}/, send(match.gsub(/[^\w\_]/, '')))
        end

        notification = NotifyOn::Notification.create(
          :recipient => send(options[:to].to_s),
          :sender => send(options[:from].to_s),
          :trigger => self,
          :description => desc
        )

        if options[:email]
          NotifyOn::NotificationMailer
            .notify(notification.id, options[:template]).deliver
        end
      end

    end

  end

end
