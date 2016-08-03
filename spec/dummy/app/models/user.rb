class User < ApplicationRecord

  # ---------------------------------------- Plugins

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # ---------------------------------------- Associations

  has_many :messages
  has_many :sent_messages, :class_name => 'Message', :foreign_key => :author_id

  # ---------------------------------------- Instance Methods

  def to_s
    email
  end

end
