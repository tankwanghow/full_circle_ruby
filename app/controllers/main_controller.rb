class MainController < ApplicationController
  def index
    @docs = (current_user.is_admin ? search_documents : search_documents.where("searchable_type <> 'User'")).page(params[:page]).per(25)
  end

private

  def search_documents
    searchable_with_types.merge(searchable_with_terms).merge(searchable_with_dates).merge(searchable_with_amounts)

  end

  def searchable_with_terms
    terms = ''
    terms = search_term.gsub(/\@[a-zA-Z]+/, '') if search_term
    !terms.blank? ? Document.search(terms) : Document.where('1=1')
  end

  def searchable_with_types
    types = []
    types = search_term.scan(/\@[a-zA-Z]+/).each { |t| t.gsub!('@', '').capitalize! } if search_term
    types.length > 0 ? Document.where(searchable_type: types) : Document.where('1=1')
  end

  def searchable_with_dates
    if search_date_from and search_date_to
      return Document.where('doc_date >= ? AND doc_date <= ?', Date.parse(search_date_from), Date.parse(search_date_to))
    end
    if search_date_from and !search_date_to
      return Document.where(doc_date: Date.parse(search_date_from)) 
    end
    return Document.where('1=1')
  end

  def searchable_with_amounts
    if search_amount_larger and search_amount_less
      return Document.where('doc_amount >= ? AND doc_amount <= ?', search_amount_larger, search_amount_less)
    end
    if search_amount_larger and !search_amount_less
      return Document.where(doc_amount: search_amount_larger)
    end
    return Document.where('1=1')
  end

end
