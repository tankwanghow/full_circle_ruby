class ApplicationController < ActionController::Base
  include Authentication
  include SentientController

  protect_from_forgery
  before_filter :login_required
end

