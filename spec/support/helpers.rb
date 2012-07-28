module Helpers
  def login_as user
    session[:user_id] = user ? (user.is_a?(User) ? user.id : create(:user).id) : nil
  end
end
