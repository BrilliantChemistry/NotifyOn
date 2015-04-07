class Person < ActiveRecord::Base
	notify_on :create, with: "Notification"
	notify_on :state, "active", with: "Notification"
	notify_on :state_transition, from: :active, to: :closed, with: "Notification"
end
