class << ActiveRecord::Base

  def receives_notifications

      has_many :notifications, -> { preloaded },
               :class_name => NotifyOn::Notification, :as => :recipient,
               :dependent => :destroy

  end

end
