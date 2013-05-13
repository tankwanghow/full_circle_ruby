require "active_support/concern"

module ValidateTransactionsBalance
  extend ActiveSupport::Concern
  def validates_transactions_balance
    transactions.each do |t| 
      raise 'Transactions generated in invalid' if !t.valid?
    end
    raise 'Transactions Not Balance!' if transactions.inject(0) { |sum, p| sum + p.amount.round(2) } != 0
  end
end