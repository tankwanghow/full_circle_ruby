class AccountTypesController < ApplicationController
  def new
    @account_type = AccountType.new
  end
end
