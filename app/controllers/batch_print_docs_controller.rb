class BatchPrintDocsController < ApplicationController
  def index
    store_param :batch_print_search
    @docs = Document.searchable_by(session[:batch_print_search]).page(params[:page]).per(10).order('updated_at desc')
  end

  def print
    print_docs = params[:doc_ids].select { |k, v| v.to_i == 1 }.map { |k,v| k.to_i }

  end

end  