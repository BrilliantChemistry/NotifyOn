class Post < ApplicationRecord

  # ---------------------------------------- Associations

  belongs_to :author, :class_name => User

  # ---------------------------------------- Attributes

  enum :state => { :draft => 0, :published => 1 }

end
