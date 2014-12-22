require 'test_helper'

class NotifyOnTest < ActiveSupport::TestCase

	def test_created_on_should_be_called

		klass = Class.new Person do
			notify_on :create, with: "Notification"
		end
		Object.const_set "TestObject", klass

		p = klass.new
		# p.expects(:notify_of_creation)
		p.expects(:send_notification)
		p.save
	end

	def test_field_changed_should_be_called
		puts "\n"
		puts "Field Change SHOULD be Called! >>"

		klass = Class.new Person do
			notify_on :state, "active", with: "Notification"
		end

		p = klass.new
		p.save!
		p.expects(:field_state_matched).once
		p.state = "active"
		p.save
		puts "\n"

	end

	def test_field_changed_should_not_be_called
		puts "\n"
		puts "Field Change Should NOT be Called! >>"
		klass = Class.new Person do
			notify_on :state, "test", with: "Notification"
		end

		p = klass.new
		p.save!
		p.expects(:field_state_matched).never
		p.state = "second_test"
		p.save
	end

	def test_other_model_does_not_have_notifications
		klass = Class.new Product do
			notify_on :state, "accepted", with: "Notification"
		end
		p = klass.new
		p.expects(:notify_of_creation).never
		p.save!
		
		p.expects(:notify_of_creation).never
		p.expects(:field_state_matched).never
		p.state = "pending"
		p.save!

		p.expects(:field_state_matched).once
		p.state = "accepted"
		p.save!
	end
end