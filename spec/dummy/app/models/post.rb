class Post < ApplicationRecord

  # ---------------------------------------- Associations

  belongs_to :author, :class_name => User

  # ---------------------------------------- Attributes

  enum :state => { :draft => 0, :pending => 1, :published => 2 }

end
