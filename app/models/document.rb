class Document < ActiveRecord::Base
  include SentientUser
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

  scope :type_in, ->(values) { where('searchable_type ~* ?', values.map { |t| '^' + t + '$' }.join('|')) }
  scope :amount_between, ->(larger, smaller) { amount_larger_eq(larger).amount_smaller(smaller) }
  scope :amount_larger_eq, ->(val) { where('doc_amount >= ?', val) }
  scope :amount_smaller_eq, ->(val) { where('doc_amount <= ?', val) }
  scope :date_between, ->(from, to) { date_larger_eq(from.to_date).date_smaller_eq(to.to_date) }
  scope :date_larger_eq, ->(val) { where('doc_date >= ?', val.to_date) }
  scope :date_smaller_eq, ->(val) { where('doc_date <= ?', val.to_date) }

  def self.searchable_by hash
    if User.current.is_admin
      searchable_by_all_types hash
    else
      searchable_by_no_user_type hash
    end
  end

  def self.searchable_by_no_user_type hash
    by_types(hash[:terms]).
      merge(by_term hash[:terms]).
      merge(by_date hash[:date_from], hash[:date_to]).
      merge(by_amount hash[:amount_larger], hash[:amount_smaller]).
      where('searchable_type <> ?', 'User')
  end

  def self.searchable_by_all_types hash
    by_types(hash[:terms]).
      merge(by_term hash[:terms]).
      merge(by_date hash[:date_from], hash[:date_to]).
      merge(by_amount hash[:amount_larger], hash[:amount_smaller])
  end

  def self.by_date start_date, end_date
    if start_date and end_date
      date_between start_date, end_date
    elsif start_date and !end_date
      date_larger_eq start_date
    elsif !start_date and end_date
      date_smaller_eq end_date
    else
      where('0=0')
    end
  end

  def self.by_amount larger, smaller
    if larger and smaller
      amount_between larger, smaller
    elsif larger and !smaller
      amount_larger_eq larger
    elsif !larger and smaller
      amount_smaller_eq smaller
    else
      where('0=0')
    end
  end

  def self.by_types query
    query ||= ''
    types = query.scan(/\@[a-zA-Z]+/).each { |t| t.gsub!('@', '').capitalize! }
    types.length > 0 ? type_in(types) : where('0=0')
  end

  def self.by_term query
    query ||= ''
    term = query.gsub(/\@[a-zA-Z]+/, '').strip
    !term.blank? ? search(term) : where('0=0')
  end

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
