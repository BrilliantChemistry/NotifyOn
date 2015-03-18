class Product < ActiveRecord::Base
	enum state: [ :pending, :accepted, :declined, :closed ]

	notify_on :state, "accepted", with: "Notification"

	notify_on :state, :declined, with: :simple_email_sent

	def simple_email_sent
		puts "Sent email"
	end
end
