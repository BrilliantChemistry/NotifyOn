class Blob < ActiveRecord::Base
	enum state: [ :pending, :accepted, :declined, :closed ]

	notify_on :state, :pending, with: "Notification"

end
