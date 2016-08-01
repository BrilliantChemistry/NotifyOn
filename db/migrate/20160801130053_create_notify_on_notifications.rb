class CreateNotifyOnNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notify_on_notifications do |t|
      t.integer :recipient_id
      t.integer :sender_id
      t.boolean :unread, :default => true
      t.integer :trigger_id
      t.string :trigger_type

      t.timestamps
    end
  end
end
