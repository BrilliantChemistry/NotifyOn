module NotifyOn
  class Notification < ApplicationRecord

    # ---------------------------------------- Associations

    belongs_to :recipient, :polymorphic => true
    belongs_to :sender, :polymorphic => true
    belongs_to :trigger, :polymorphic => true

    # ---------------------------------------- Scopes

    scope :preloaded, -> { includes(:recipient, :sender, :trigger) }

  end
end
