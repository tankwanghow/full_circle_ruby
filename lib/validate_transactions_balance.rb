require "active_support/concern"

module ValidateTransactionsBalance
  extend ActiveSupport::Concern
  module InstanceMethods
    def validates_transactions_balance
      raise 'Transactions Not Balance!' if transactions.inject(0) { |sum, p| sum + p.amount } != 0
    end    
  end
end