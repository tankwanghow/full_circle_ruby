class MainController < ApplicationController
  def index
    @docs = current_user.is_admin ? pgsearch_documents : pgsearch_documents.where("searchable_type <> 'User'")
  end

private

  def pgsearch_documents
    return PgSearch::Document.all if search_term.blank?
    return searchable_with_types if searchable_with_terms.nil?
    return searchable_with_terms if searchable_with_types.nil?
    searchable_with_types.merge(searchable_with_terms)
  end

  def searchable_with_terms
    terms = search_term.gsub(/\@[a-zA-Z]+/, '')
    !terms.blank? ? PgSearch.multisearch(terms) : nil
  end

  def searchable_with_types
    types = search_term.scan(/\@[a-zA-Z]+/).each { |t| t.gsub!('@', '').capitalize! }
    types.length > 0 ? PgSearch::Document.where(searchable_type: types) : nil
  end

  def search_term
    params[:search] ? params[:search][:terms] : ''
  end

end
