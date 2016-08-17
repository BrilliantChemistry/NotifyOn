module NotifyOn
  class Notification < ApplicationRecord

    # ---------------------------------------- Associations

    belongs_to :recipient, :polymorphic => true
    belongs_to :sender, :polymorphic => true
    belongs_to :trigger, :polymorphic => true

    # ---------------------------------------- Scopes

    scope :preloaded, -> { includes(:recipient, :sender, :trigger) }
    scope :unread, -> { where(:unread => true) }
    scope :recent, -> { order(:created_at => :desc) }

    # ---------------------------------------- Instance Methods

    def read!
      update_columns(:unread => false)
    end

  end
end
