module NotifyOn
  class Notification < ApplicationRecord

    belongs_to :recipient, :polymorphic => true
    belongs_to :sender, :polymorphic => true
    belongs_to :trigger, :polymorphic => true

  end
end
