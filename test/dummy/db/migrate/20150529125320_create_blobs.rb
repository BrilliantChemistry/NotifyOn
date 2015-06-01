class CreateBlobs < ActiveRecord::Migration
	def change
		create_table :blobs do |t|
			t.string :name
			t.string :state, nullable: false, default: 0

			t.timestamps
		end
	end
end
