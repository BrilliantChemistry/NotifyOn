require 'test_helper'

class NotifyOnTest < ActiveSupport::TestCase

	def test_created_on_should_be_called
		p = Person.new
		p.expects(:create_notification)
		p.save
	end

	def test_field_changed_should_be_called
		# puts "\n"
		# puts "Field Change SHOULD be Called! >>"

		p = Person.new
		p.save!
		p.expects(:field_state_matched).once
		p.state = "pending"
		p.save
		# puts "\n"

	end

	def test_field_changed_should_not_be_called
		# puts "\n"
		# puts "Field Change Should NOT be Called! >>"
		p = Person.new
		p.save!
		p.expects(:field_state_matched).never
		p.state = "second_test"
		p.save
	end

	def test_field_change_called_on_creation
		# puts "Creating BLOB for the first time."
		# puts Blob.notify_list
		b = Blob.new
		b.expects(:field_state_matched).once
		b.save!
		b.reload
		b.save
	end

	def test_other_model_does_not_have_notifications
		p = Product.new
		p.expects(:notify_of_creation).never
		p.save!

		p.expects(:notify_of_creation).never
		p.expects(:field_state_matched).never
		p.state = :pending
		p.save!

		p.expects(:field_state_matched).once
		p.state = :accepted
		p.save!
	end

	def test_class_configuration_should_be_model_specific
		# Load up the other classes with config to make sure it doesn't affect our person.
		# puts Category.notify_list
		# puts Job.notify_list

		p = Product.new
		p.expects(:notify_of_creation).never
		p.save!
	end

	def test_message_sent
		p = Product.new
		p.save!

		p.expects(:send_message).once
		p.expects(:create_notification).never

		p.state = :declined
		p.save!
	end

	def test_state_transition
		p = Person.new
		# get rid of that first notify on create...
		p.state = "active"
		p.save

		# now we only want one...
		p.expects(:field_state_matched).once

		# p.state = "dummy"
		# p.save
		# puts "setting state to active."
		# p.state = "active"
		# p.save

		# puts "reloading."
		# p.reload
		# puts "\n"

		p.state = "closed"
		p.save
	end

	def test_state_transition_not_fired
		p = Person.new
		p.expects(:field_state_matched).never
		p.state = "dummy"
		p.save

		p.state = "finished"
		p.save
	end
end