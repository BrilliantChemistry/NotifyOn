class Message < ApplicationRecord

  # ---------------------------------------- Plugins

  notify_on :create, :to => :user, :from => :author,
            :message => '{author.email} sent you a message.', :email => true,
            :template => 'new_message', :link => [:message_path, :self],
            :pusher => { :channel => "presence-message-{id}",
                         :event => :new_message }

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
