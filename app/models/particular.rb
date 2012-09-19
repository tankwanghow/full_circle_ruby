class Particular < ActiveRecord::Base
  belongs_to :particular_type
  belongs_to :doc, polymorphic: true
  validates_presence_of :particular_type_name, :note, :unit
  validates_numericality_of :quantity, :unit_price

  include ValidateBelongsTo
  validate_belongs_to :particular_type, :name

  def simple_audit_string
    searchable_string
  end

  def searchable_string
    [ particular_type.name, note, quantity.to_s,
      unit, unit_price.to_money.format ].join ' '
  end

  def total
    (quantity * unit_price).round 2
  end

  def build_transactions main_account, no_default_transaction=false
    def_trans = default_transaction(main_account)
    opp_trans = oppsite_transaction(main_account)
    return [opp_trans] if no_default_transaction
    if def_trans[:account] == opp_trans[:account] && def_trans[:debit] == opp_trans[:credit]
      return []
    end
    [def_trans, opp_trans]
  end

  private

    def default_transaction main_account 
      fill_db_cr( 
        transaction_date: doc.doc_date, 
        account: main_account, 
        note: [particular_type.name, note].join(' '), 
        user: User.current)
    end

    def oppsite_transaction(main_account)
      def_trans = default_transaction(main_account)
      {
        transaction_date: doc.doc_date,
        account: particular_type.account || main_account,
        note: [particular_type.name, note].join(' '),
        debit: def_trans[:debit] > 0 ? 0 : def_trans[:credit],
        credit: def_trans[:credit] > 0 ? 0 : def_trans[:debit],
        user: User.current
      }
    end

    def fill_db_cr(hash)
      if particular_type.party_type == 'Incomes'
        hash.merge debit: total.abs, credit: 0
      else
        hash.merge debit: 0, credit: total.abs
      end
    end

end
