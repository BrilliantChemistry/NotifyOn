class << ActiveRecord::Base

  def notify_on(action, options = {})

    has_many :notifications, -> { preloaded },
             :class_name => NotifyOn::Notification, :as => :trigger,
             :dependent => :destroy

    attr_accessor :skip_notifications

    notify_on_to = if reflect_on_association(options[:to]).nil?
      options[:to_class_name].to_s
    else
      reflect_on_association(options[:to]).class_name
    end

    case action.to_sym
    when :create

      after_create :"notify_#{options[:to]}_on_create"

      define_method "notify_#{options[:to]}_on_create" do
        return if skip_notifications == true
        return if options[:skip_if].present? && send(options[:skip_if]) == true
        to = send(options[:to].to_s)
        (to.is_a?(Array) ? to : [to]).each do |recipient|

          NotifyOn::Notification.transaction do
            notification = NotifyOn::Notification.create!(
              :recipient => recipient,
              :sender => options[:from].blank? ? nil : send(options[:from].to_s),
              :trigger => self,
              :description_raw => options[:message],
              :link_raw => options[:link],
              :options => options
            )

            notification.push! if options[:pusher].present?
            notification.send_email! if options[:email].present?
          end
        end
      end

    end

  end

end
