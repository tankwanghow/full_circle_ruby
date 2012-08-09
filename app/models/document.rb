class Document < ActiveRecord::Base
  self.table_name = 'search_documents'
  belongs_to :searchable, polymorphic: true

  before_validation :update_record_value

  include PgSearch
  pg_search_scope :search, against: :content, 
                  using: { 
                    tsearch: { any_word: true, prefix: true },
                    dmetaphone: {},
                    trigram: {}
                  }

  private

  def update_record_value
    if searchable.searchable_options[:doc_date]
      self.doc_date = searchable.send(searchable.searchable_options[:doc_date])
    else
      self.doc_date = Date.today
    end
    self.doc_amount = searchable.send(searchable.searchable_options[:doc_amount]) if searchable.searchable_options[:doc_amount]
    methods = Array.wrap(searchable.searchable_options[:content])
    searchable_text = methods.map { |symbol| searchable.send(symbol) }.compact.join("; ")
    self.content = searchable_text
  end
end
