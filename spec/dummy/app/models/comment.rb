class Comment < ApplicationRecord

  # ---------------------------------------- Associations

  belongs_to :user
  belongs_to :post

  has_one :post_author, :through => :post, :source => :author

end
