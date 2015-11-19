class Person < ActiveRecord::Base
	notify_on :create, with: "Notification"
	notify_on :state, "pending", with: "Notification"
	notify_on :state_transition, from: :active, to: :closed, with: "Notification"

	enum :state => [ :pending, :active, :closed, :bogus, :finished ]
end
