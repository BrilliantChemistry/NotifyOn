module Notify
	module NotifyOn
		extend ActiveSupport::Concern

		# instance methods
		def notify_of_creation
			# puts "notify_of_creation >> "
			# Rails.logger.warn "NOTIFY_OF_CREATION: #{self}"

			self.class.notify_list[:create].each do |notification|
				send_notification(notification)
			end
		end

		def notify_of_state_change
			# puts "notify_of_state_change >> "
			self.class.notify_list[:change].each do |notification|
				Rails.logger.info "STATE_CHANGE with #{notification[:class_name]}: condition #{notification[:field]} = #{notification[:value]} on #{self}"

				trigger_field = notification[:field].to_sym
				trigger_value = notification[:value]

				# puts"\n"
				# puts "#{trigger_field} == #{trigger_value}"
				# puts "Changed attributes: #{self.changed_attributes}"
				# puts "Was changed: #{self.changed_attributes.key?(trigger_field)}"
				# puts "value: '#{self.public_send(trigger_field)}' and need: '#{trigger_value}'"
				# puts "Equal: #{self.read_attribute(trigger_field) == trigger_value}"
				Rails.logger.info "Object is: '#{self.public_send(trigger_field)}'"
				if self.changed_attributes.key?(trigger_field) && self.public_send(trigger_field) == trigger_value
					# puts "match"
					Rails.logger.info "Match! Sending."
					field_state_matched(notification)
				# else
				# 	puts "no match"
				end
			end
		end

		# really just for testing state logic...
		def field_state_matched(notification)
			send_notification(notification)
		end


		def send_notification(notification)
			klass = Object.const_get notification[:class_name]
			klass.create_and_save(self)
		end

		# def notify_config
		# 	self.notify_attributes
		# end

		# add your static(class) methods here
		module ClassMethods
			cattr_accessor :notify_list

			def notify_on(type, *args)
				options = args.extract_options!

				# Rails.logger.warn "NOTIFICATION_SCHEME: #{type}"

				# if we are watching a field for a value change, it's the second argument to this method
				if !args[0].instance_of?(Hash)
					value = args[0]
				end

				if options[:with].blank?
					raise ":with must specify a class name as a string to send as the notification"
				end

				notification = {}
				notification[:scheme] = type
				notification[:class_name] = options[:with]

				# attempt to load the class and fail if not able to
				# begin # the rescue block is not needed as runtime provides a better message.
				test = Object.const_get notification[:class_name]
				# rescue LoadError => e
				# 	raise "notify_on: #{type} -> Unable to load class (#{notification[:class_name]})"
				# end


				if type == :create
					# puts "Setting up create callback."
					after_create  :notify_of_creation

				else

					notification[:scheme] = :change
					notification[:field] = type.to_sym
					# TODO: validate object has specified field.
					notification[:value] = value

					if notification[:value].blank?
						ActiveSupport::Deprecation.warn("State must be provided when specifying :state_change for notification_scheme")
					end

					after_update  :notify_of_state_change
				end

				# puts self.notify_list

				self.notify_list ||= {}
				self.notify_list[notification[:scheme]] ||= []
				self.notify_list[notification[:scheme]] << notification
			end
		end
	end
end

# include the extension
ActiveRecord::Base.send(:include, Notify::NotifyOn)