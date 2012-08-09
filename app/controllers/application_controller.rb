class ApplicationController < ActionController::Base
  include Authentication
  include SentientController

  protect_from_forgery
  before_filter :login_required
  before_filter :save_search_term_to_session

private

  def search_term
    params[:search] ? params[:search][:terms] : session[:searchable_term]
  end

  def save_search_term_to_session
    session[:searchable_term] = search_term
  end

end

