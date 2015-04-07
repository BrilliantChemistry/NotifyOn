class Person < ActiveRecord::Base
	notify_on :create, with: "Notification"
	notify_on :state, "active", with: "Notification"
	notify_on :exited_state, :active, with: "Notification"
end
