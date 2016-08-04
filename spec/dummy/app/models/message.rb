class Message < ApplicationRecord

  # ---------------------------------------- Plugins

  notify_on :create, :to => :user, :from => :author,
            :message => '{author_email} sent you a message.', :email => true,
            :template => 'new_message', :link => [:message_path, :self]

  # ---------------------------------------- Associations

  belongs_to :user
  belongs_to :author, :class_name => User

  # ---------------------------------------- Validations

  validates :user, :author, :content, :presence => true

  # ---------------------------------------- Instance Methods

  def author_email
    author.email
  end

end
