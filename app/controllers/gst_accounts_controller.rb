class GstAccountsController < ApplicationController

  def index
    store_param :gst_accounts
    session[:gst_accounts][:month] ||= Date.current.month - 1
    @date = "#{Date.today.year}-#{session[:gst_accounts][:month]}-01".to_date.end_of_month
    @accounts = Account.gst_accounts
    @gst_control_account = @accounts.select { |t| t.name1 =~ /Control/ }.first
    @gst_expense_account = @accounts.select { |t| t.name1 =~ /Expense/ }.first
  end

  def create
    gsi = Account.find params[:gst_control_id].to_i
    aci = Account.find params[:account_id].to_i
    balance = params[:balance].to_d
    date = "#{Date.today.year}-#{session[:gst_accounts][:month]}-01".to_date.end_of_month
    j = Journal.new(doc_date: date)
    if balance < 0
      aci_balance = balance.abs
      gsi_balance = -balance.abs
    else
      aci_balance = -balance.abs
      gsi_balance = balance.abs
    end
    j.transactions.build(account_id: aci.id, note: "Transfer to #{gsi.name1}", amount: aci_balance)
    j.transactions.build(account_id: gsi.id, note: "Transfer from #{aci.name1}", amount: gsi_balance)
    j.save
    redirect_to gst_accounts_path
  end

end
