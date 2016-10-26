class Message < ApplicationRecord

  # ---------------------------------------- Plugins

  # Test that the basics work with the model config. All other features and
  # variations are tested using the bulk config.
  notify_on :create,
            :to => :user,
            :from => :author,
            :message => '{author.email} sent you a message.',
            :link => 'message_path(:self)',
            :email => true

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

  def pdf_filename
    'myfile.pdf'
  end

  def pdf_file
    @pdf_file ||= open('http://loremflickr.com/200/200')
  end

end
