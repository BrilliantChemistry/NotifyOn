class Message < ApplicationRecord

  belongs_to :user
  belongs_to :author, :class_name => User

  validates :user, :author, :content, :presence => true

  notify_on :create, :to => :user, :from => :author,
            :message => '{author_email} sent you a message.'

  def author_email
    author.email
  end

end
