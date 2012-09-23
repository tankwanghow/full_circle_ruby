class MainController < ApplicationController

  def index
    store_param :search
    @docs = Document.searchable_by(session[:search]).page(params[:page]).per(25).order('updated_at desc')
  end

end
