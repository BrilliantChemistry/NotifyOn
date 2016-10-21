class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.integer :author_id
      t.text :body
      t.integer :state, :default => 0

      t.timestamps
    end
  end
end
