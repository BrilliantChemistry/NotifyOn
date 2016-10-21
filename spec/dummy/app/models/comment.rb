class Comment < ApplicationRecord

  # ---------------------------------------- Associations

  belongs_to :user
  belongs_to :post

end
