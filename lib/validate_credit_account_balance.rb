require "active_support/concern"

module ValidateCreditAccountBalance
  extend ActiveSupport::Concern
  
  module ClassMethods
    def validate_credit_account_balance account, amount, msg='not enough!'
      class_eval <<-BOL
        def credit_account_balance_enough
          t_amt = transactions.where(account_id: #{account}.id).sum(:amount).abs
          if Transaction.where(account_id: #{account}.id).sum(:amount) - #{amount} + t_amt < 0
            errors.add '#{amount}', '#{msg}'
          end
        end
      BOL
      validate :credit_account_balance_enough
    end
  end

end