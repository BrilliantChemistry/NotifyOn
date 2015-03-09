module Notify
	module NotifyOn
		extend ActiveSupport::Concern

		# instance methods
		def notify_of_creation
			Rails.logger.debug "notify_of_creation >> [#{self.class.name}] "
			Rails.logger.debug self.class.notify_list
			# puts clazz.notify_list

			config = self.class.notify_list[self.class.name]

			# Rails.logger.warn "NOTIFY_OF_CREATION: #{self}"

			config[:create].each do |notification|
				Rails.logger.info "CREATE on #{self} with #{notification[:class_name]}"
				send_notification(notification)
			end
		end

		def notify_of_state_change
			# puts "notify_of_state_change >> "
			config = self.class.notify_list[self.class.name]
			config[:change].each do |notification|
				trigger_field = notification[:field].to_sym
				trigger_value = notification[:value]

				Rails.logger.info "STATE_CHANGE with #{notification[:class_name]}: condition #{notification[:field]} = #{notification[:value]} on #{self}, dirty? #{self.changed_attributes.key?(trigger_field)}, value: '#{self.public_send(trigger_field)}'"

				# puts"\n"
				# puts "#{trigger_field} == #{trigger_value}"
				# puts "Changed attributes: #{self.changed_attributes}"
				# puts "Was changed: #{self.changed_attributes.key?(trigger_field)}"
				# puts "value: '#{self.public_send(trigger_field)}' and need: '#{trigger_value}'"
				# puts "Equal: #{self.read_attribute(trigger_field) == trigger_value}"
				if self.changed_attributes.key?(trigger_field) && self.public_send(trigger_field).to_s == trigger_value.to_s
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
				notification[:model_name] = name

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
				model_config = self.notify_list[notification[:model_name]]
				model_config ||= {}
				model_config[notification[:scheme]] ||= []
				model_config[notification[:scheme]] << notification
				self.notify_list[notification[:model_name]] = model_config
			end
		end
	end
end

# include the extension
ActiveRecord::Base.send(:include, Notify::NotifyOn)