class Category < ActiveRecord::Base
	notify_on :create, with: "Notification"
end
