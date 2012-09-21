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

  scope :type_like, ->(val) { where('searchable_type ilike ?', val) }
  scope :date_between, ->(from, to) { where('doc_date >= ? AND doc_date <= ?', from.to_date, to.to_date) }
  scope :amount_between, ->(from, to) { where('doc_amount >= ? AND doc_amount <= ?', from, to) }
  scope :date_is, ->(val) { where('doc_date = ?', val.to_date) }
  scope :amount_is, ->(val) { where('doc_amount = ?', val) }

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
