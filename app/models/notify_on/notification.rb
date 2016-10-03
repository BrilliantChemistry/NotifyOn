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

    def recipient_type=(sType)
      super(sType.to_s.classify.constantize.base_class.to_s)
    end

    def sender_type=(sType)
      super(sType.to_s.classify.constantize.base_class.to_s)
    end

    def trigger_type=(sType)
      super(sType.to_s.classify.constantize.base_class.to_s)
    end

    # ---------------------------------------- Scopes

    scope :preloaded, -> { includes(:recipient, :sender, :trigger) }
    scope :unread, -> { where(:unread => true) }
    scope :recent, -> { order(:updated_at => :desc) }

    scope :from_with_type, ->(from, type) {
      where(:sender => from, :trigger_type => type)
    }

    # ---------------------------------------- Callbacks

    after_save :convert_attrs

    # ---------------------------------------- Class Methods

    def self.mark_read_for(recipient, trigger)
      where(:recipient => recipient, :trigger => trigger)
        .update_all(:unread => false)
    end

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

    def method_missing(method_name, *args, &blk)
      return Hashie::Mash.new(options) if method_name.to_s == 'opts'
      super
    end

    # ---------------------------------------- Private Methods

    private

      def convert_attrs
        update_columns(:description_cached => convert_string(description_raw),
                       :link_cached => convert_link(link_raw))
      end

  end
end
