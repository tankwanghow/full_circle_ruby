class MainController < ApplicationController
  def index
    @docs = current_user.is_admin ? search_documents : search_documents.where("searchable_type <> 'User'")
  end

private

  def search_documents
    return Document.where('1=1') if search_term.blank?
    return searchable_with_types if searchable_with_terms.nil?
    return searchable_with_terms if searchable_with_types.nil?
    searchable_with_types.merge(searchable_with_terms)
  end

  def searchable_with_terms
    terms = search_term.gsub(/\@[a-zA-Z]+/, '')
    !terms.blank? ? Document.search(terms) : nil
  end

  def searchable_with_types
    types = search_term.scan(/\@[a-zA-Z]+/).each { |t| t.gsub!('@', '').capitalize! }
    types.length > 0 ? Document.where(searchable_type: types) : nil
  end

end
