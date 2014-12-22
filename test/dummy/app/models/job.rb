class Job < ActiveRecord::Base
	notify_on :create, with: "Notification"
	notify_on :state, :active, with: "Notification"
end
