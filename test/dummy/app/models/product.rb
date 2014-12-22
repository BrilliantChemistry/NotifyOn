class Product < ActiveRecord::Base
	enum state: [ :pending, :accepted, :declined, :closed ]
end
