require "active_support/concern"

module StoreSearchParamsSession
  extend ActiveSupport::Concern
  
  included do
    before_filter :save_search_params_to_session
  end
  
private

  def search_term
    params[:search] ? params[:search][:terms] : session[:search_term]
  end

  def search_date_from
    params[:search] ? params[:search][:date_from] : session[:search_date_form]
  end

  def search_date_to
    params[:search] ? params[:search][:date_to] : session[:search_date_to]
  end

  def search_amount_larger
    params[:search] ? params[:search][:amount_larger] : session[:search_amount_larger]
  end

  def search_amount_less
    params[:search] ? params[:search][:amount_less] : session[:search_amount_less]
  end

  def save_search_params_to_session
    drop_blank_search_params
    session[:search_term] = search_term
    session[:search_date_form] = search_date_from
    session[:search_date_to] = search_date_to
    session[:search_amount_larger] = search_amount_larger
    session[:search_amount_less] = search_amount_less
  end

  def drop_blank_search_params
    if params[:search]
      params[:search].delete_if { |k,v| v.blank? }
    end
  end

end