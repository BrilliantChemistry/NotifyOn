class Message < ApplicationRecord

  # ---------------------------------------- Plugins

  notify_on :create, :to => :user, :from => :author, :skip_if => :skip?,
            :message => '{author.email} sent you a message.',
            :link => 'message_path(:self)',
            :email => { :template => 'new_message', :send_unless => :delayed? },
            :pusher => { :channel => "presence-message-{id}",
                         :event => 'new-message-{id}',
                         :data => { :is_chat => true } }

  # ---------------------------------------- Attributes

  attr_accessor :delayed

  # ---------------------------------------- Associations

  belongs_to :user
  belongs_to :author, :class_name => User

  # ---------------------------------------- Validations

  validates :user, :author, :content, :presence => true

  # ---------------------------------------- Instance Methods

  def delayed?
    content.start_with?('[DELAYED]')
  end

  def skip?
    content.start_with?('[SKIP]')
  end

end
