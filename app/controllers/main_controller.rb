class MainController < ApplicationController

  def index
    store_param :search
    @docs = (current_user.is_admin ? search_documents : search_documents.where("searchable_type <> 'User'")).page(params[:page]).per(25).order('updated_at desc')
  end

private

  def search_documents
    searchable_with_types.merge(searchable_with_terms).merge(searchable_with_dates).merge(searchable_with_amounts)
  end

  def searchable_with_terms
    terms = ''
    terms = session[:search_terms].gsub(/\@[a-zA-Z]+/, '') if !session[:search_terms].blank?
    !terms.blank? ? Document.search(terms) : Document.where('1=1')
  end

  def searchable_with_types
    types = []
    types = session[:search_terms].scan(/\@[a-zA-Z]+/).each { |t| t.gsub!('@', '').capitalize! } if !session[:search_terms].blank?
    types.length > 0 ? Document.type_like(types) : Document.where('1=1')
  end

  def searchable_with_dates
    if !session[:search_date_from].blank? and !session[:search_date_to].blank?
      return Document.date_between(session[:search_date_from], session[:search_date_to])
    end
    if !session[:search_date_from].blank? and session[:search_date_to].blank?
      return Document.date_is(session[:search_date_from]) 
    end
    return Document.where('1=1')
  end

  def searchable_with_amounts
    if !session[:search_amount_larger].blank? and !session[:search_amount_less].blank?
      return Document.amount_between(session[:search_amount_larger], session[:search_amount_less])
    end
    if !session[:search_amount_larger].blank? and session[:search_amount_less].blank?
      return Document.amount_is(session[:search_amount_larger])
    end
    return Document.where('1=1')
  end

end
