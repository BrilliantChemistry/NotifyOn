class Blob < ActiveRecord::Base
	enum state: [ :pending, :accepted, :declined, :closed ]

	before_validation :default_values

	notify_on :state, :pending, with: "Notification"

	protected

	def default_values
		self.state = :pending
	end
end
