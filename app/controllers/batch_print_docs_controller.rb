class BatchPrintDocsController < ApplicationController
  def index
    params[:batch_print_search] ||= {}
    @docs = Document.searchable_by(params[:batch_print_search]).page(params[:page]).per(25).order('updated_at desc')
  end
end  