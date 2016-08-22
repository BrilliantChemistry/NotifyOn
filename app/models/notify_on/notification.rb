module NotifyOn
  class Notification < ApplicationRecord

    # ---------------------------------------- Plugins

    include NotifyOn::StringInterpolation,
            NotifyOn::PusherSupport,
            NotifyOn::EmailSupport

    # ---------------------------------------- Attributes

    serialize :options, Hash

    # ---------------------------------------- Associations

    belongs_to :recipient, :polymorphic => true
    belongs_to :sender, :polymorphic => true
    belongs_to :trigger, :polymorphic => true

    # ---------------------------------------- Scopes

    scope :preloaded, -> { includes(:recipient, :sender, :trigger) }
    scope :unread, -> { where(:unread => true) }
    scope :recent, -> { order(:created_at => :desc) }

    # ---------------------------------------- Callbacks

    after_save :convert_attrs

    # ---------------------------------------- Instance Methods

    def read!
      update_columns(:unread => false)
    end

    def link
      link_cached || convert_link(link_raw)
    end

    def description
      description_cached || convert_string(description_raw)
    end

    # ---------------------------------------- Private Methods

    private

      def convert_attrs
        update_columns(:description_cached => convert_string(description_raw),
                       :link_cached => convert_link(link_raw))
      end

  end
end
