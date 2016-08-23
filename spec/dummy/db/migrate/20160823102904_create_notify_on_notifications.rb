class CreateNotifyOnNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notify_on_notifications do |t|
      t.integer :recipient_id
      t.string :recipient_type
      t.integer :sender_id
      t.string :sender_type
      t.boolean :unread, :default => true
      t.integer :trigger_id
      t.string :trigger_type
      t.text :description_raw
      t.text :description_cached
      t.string :link_raw
      t.string :link_cached
      t.boolean :use_default_email, :default => false
      t.text :options
      t.timestamps
    end
  end
end
