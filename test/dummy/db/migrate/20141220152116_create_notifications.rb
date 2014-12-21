class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :sender
      t.integer :recipient
      t.integer :object
      t.timestamp :created_at
      t.boolean :unread

      t.timestamps
    end
  end
end
