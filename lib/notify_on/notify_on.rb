class << ActiveRecord::Base

  def notify_on(action, options = {})

    include NotifyOn::Helpers

    has_many :notifications, -> { preloaded },
             :class_name => NotifyOn::Notification, :as => :trigger,
             :dependent => :destroy

    attr_accessor :skip_notifications

    if action.to_sym == :create
      method_name = "notify_#{options[:to]}_on_create"
      after_create(method_name.to_sym)
      define_method(method_name) { create_notify_on_notifications(options) }
    else
      action_to_s = action.to_s.gsub(/\?/, '')
      when_to_s = options[:when].to_s.gsub(/\?/, '')
      method_name = "notify_#{options[:to]}_on_#{action_to_s}_when_#{when_to_s}"
      after_save(method_name.to_sym)
      define_method(method_name) do
        return unless action.to_sym == :save || send(action)
        return unless options[:when].present? && send(options[:when])
        create_notify_on_notifications(options)
      end
    end

  end

end
