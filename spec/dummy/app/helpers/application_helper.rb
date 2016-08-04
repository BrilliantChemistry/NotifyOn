module ApplicationHelper

  def avatar(user)
    email_hash = Digest::MD5.hexdigest(user.email.downcase)
    "https://www.gravatar.com/avatar/#{email_hash}"
  end

end
