module Notify
	module NotifyOn
		extend ActiveSupport::Concern

		# instance methods
		def notify_of_creation
			# Note: SELF is the ActiveRecord model object
			Rails.logger.debug "notify_of_creation >> [#{self.class.name}] "
			Rails.logger.debug self.class.notify_list
			# puts clazz.notify_list

			config = self.class.notify_list[self.class.name]

			# Rails.logger.warn "NOTIFY_OF_CREATION: #{self}"

			config[:create].each do |notification|
				Rails.logger.info "CREATE on #{self} with #{notification[:class_name]}"
				create_notification(notification)
			end
		end

		def notify_of_state_change
			# Note: SELF is the ActiveRecord model object
			Rails.logger.info "notify_of_state_change for [#{self.class.name}] >>"
			config = self.class.notify_list[self.class.name]
			if config[:match].present?
				config[:match].each_with_index do |notification, index|
					trigger_field = notification[:field].to_sym
					trigger_value = notification[:value]

					Rails.logger.info "Checking for STATE_MATCH with #{notification[:class_name].present? ? notification[:class_name] : "send " + notification[:method_name].to_s}: #{notification[:field]} = #{notification[:value]} on #{self.class.name}[#{self.id}], dirty? #{self.changed_attributes.key?(trigger_field)}, value: '#{self.public_send(trigger_field)}'"

					# puts"\n"
					# puts "Checking Condition: #{trigger_field} == #{trigger_value}"
					# puts "Changed attributes: #{self.changed_attributes}"
					# puts "Was changed: #{self.changed_attributes.key?(trigger_field)}"
					# puts "value: '#{self.public_send(trigger_field)}' and need: '#{trigger_value}'"
					# puts "Equal: #{self.public_send(trigger_field).to_s == trigger_value.to_s}"

					# puts "#{self.class.name}.#{trigger_field} is enum: #{notification[:enum?]} && #{notification[:enum_default_value].to_s} == #{trigger_value.to_s} && #{self.public_send(trigger_field)} == nil"

					if self.changed_attributes.key?(trigger_field) && self.public_send(trigger_field).to_s == trigger_value.to_s
						# puts "Condition: matched #{trigger_field}: #{trigger_value}"
						Rails.logger.info "Found Match! Sending."
						field_state_matched(notification)
					elsif notification[:enum?] && notification[:enum_default_value].to_s == trigger_value.to_s && self.public_send(trigger_field) == nil
						Rails.logger.info "WARNING: #{self.class.name}.#{trigger_field} is an enum set to match against a default value of #{trigger_value} but is nil. You need to set a value for #{trigger_field} before saving."

					end
				end
			end

			if config[:transition].present?
				config[:transition].each do |notification|
					trigger_field = notification[:field].to_sym
					old_value = notification[:old_value]
					new_value = notification[:new_value]

					Rails.logger.info "Checking for STATE_EXITED with #{notification[:class_name].present? ? notification[:class_name] : "send " + notification[:method_name].to_s}: condition #{notification[:field]} left #{notification[:value]} on #{self}, dirty? #{self.changed_attributes.key?(trigger_field)}, value: '#{self.public_send(trigger_field)}'"

					# puts"\n"
					# puts "Checking Condition: #{trigger_field} == #{trigger_value}"
					# puts "Changed attributes: #{self.changed_attributes}"
					# puts "Was changed: #{self.changed_attributes.key?(trigger_field)}"
					# puts "value: '#{self.public_send(trigger_field)}' and need: '#{trigger_value}'"
					# puts "Equal: #{self.public_send(trigger_field).to_s == trigger_value.to_s}"
					if self.changed_attributes.key?(trigger_field) && # trigger_field was updated
							self.changed_attributes[trigger_field].to_s == old_value.to_s && # trigger_field used to equal trigger_value
							self.public_send(trigger_field).to_s == new_value.to_s # trigger_field no longer equals trigger_value
						# puts "Condition: transition #{trigger_field}: #{old_value} to #{new_value}"
						Rails.logger.info "Found Transition! Sending."
						field_state_matched(notification)
					else
						# puts "Condition: no match"
					end
				end
			end
		end

		# really just for testing state logic...
		def field_state_matched(notification)
			# puts "field_state_matched called!"
			if notification[:class_name].present?
				# puts "Creating a notification for #{notification[:class_name]}"
				create_notification(notification)
			elsif notification[:method_name].present?
				# puts "Sending a message for #{notification[:method_name]}"
				send_message(notification)
			else
				# puts "Failed to detect what's up"
				Rails.logger.error "Unable to send notification, class name or method symbol was not used."
			end
		end

		def send_message(notification)
			# method name is a fire and forget type notification...
			self.send(notification[:method_name])
		end

		def create_notification(notification)
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
					raise ":with must specify a class name as a string or action as a symbol to send as the notification"
				end

				notification = {}
				notification[:scheme] = type

				case options[:with]
					when Symbol
						notification[:method_name] = options[:with]
					when String
						notification[:class_name] = options[:with]
						# attempt to load the class and fail if not able to
						# begin # the rescue block is not needed as runtime provides a better message.
						test = Object.const_get notification[:class_name]
						# rescue LoadError => e
						# 	raise "notify_on: #{type} -> Unable to load class (#{notification[:class_name]})"
						# end
				end
				notification[:model_name] = name




				if type == :create
					# puts "Setting up create callback."
					after_create  :notify_of_creation

				elsif type.to_s.ends_with? '_transition'
					# puts "State transition callback."
					notification[:scheme] = :transition
					notification[:field] = type.to_s.gsub(/_transition/, '').to_sym
					notification[:old_value] = options[:from]
					notification[:new_value] = options[:to]

					if notification[:old_value].blank? || notification[:new_value].blank?
						ActiveSupport::Deprecation.warn("Transition values must be provided (:from, :to) when specifying :field_transition for notification_scheme")
					end

					after_update  :notify_of_state_change
				else
					# puts "State match callback."
					notification[:scheme] = :match
					notification[:field] = type.to_sym
					# TODO: validate object has specified field.
					notification[:value] = value

					if notification[:value].blank?
						ActiveSupport::Deprecation.warn("State must be provided when specifying :state_change for notification_scheme")
					end

					# we need to check if the caller wants to notify on the first value of an enum field.  In this case,
					# they may expect that when the object is created and saved, the notification would go out.
					# Unfortunately, Rails doesn't have built in defaults for enums. We rely on the database default to set it for us
					# which means the default isn't set until after being read back from the database. :/
					# This scenario is a bag of hurt and we are going to warn the user it won't work.
					if self.respond_to?(type.to_s.pluralize)
						notification[:enum?] = true
						# we have an rails 4.1 enum, get the possible values...
						enum_values = self.send(type.to_s.pluralize)
						if enum_values
							# get the value with integer value 0 (the default or first)
							default = enum_values.key(0)
							notification[:enum_default_value] = default
							if default.to_sym == notification[:value].to_sym
								# If we were asked to notify on the default, then we need to put out a warning message about that.
								ActiveSupport::Deprecation.warn("Asked to notify on #{self.name}.#{type.to_s} == #{notification[:value]}, this is the expected default value and is NOT supported. Instead use notify_on :create instead.")
							end
						end
					end

					after_update :notify_of_state_change
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