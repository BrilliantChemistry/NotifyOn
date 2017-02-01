module FeatureHelpers

  def sign_in_as(user, options = {})
    if options[:ui].present?
      visit root_path
      sign_out(:ui => true)
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign In'
    else
      login_as(user, :scope => :user)
    end
  end

  def sign_out(options = {})
    options[:ui].present? ? click_link('Sign Out') : logout(:user)
  end

end
