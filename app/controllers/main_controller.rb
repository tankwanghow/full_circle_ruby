class MainController < ApplicationController

  def index
    store_param :search
    @docs = (current_user.is_admin ? search_documents : search_documents.where("searchable_type <> 'User'")).page(params[:page]).per(25).order('updated_at desc')
  end

private

  def search_documents
    Document.searchable_by session[:search_terms], 
                           session[:search_date_from], session[:search_date_to], 
                           session[:search_amount_larger], session[:search_amount_smaller]
  end

end
