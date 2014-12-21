class Notification < ActiveRecord::Base
	def self.create_and_save(obj)
		puts "Would create and save a notification for: #{obj}"
	end
end
