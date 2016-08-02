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
      t.text :description
    end
  end
end
