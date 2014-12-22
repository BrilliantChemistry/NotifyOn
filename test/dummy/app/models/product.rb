class Product < ActiveRecord::Base
	enum state: [ :pending, :accepted, :declined, :closed ]

	notify_on :state, "accepted", with: "Notification"
end
