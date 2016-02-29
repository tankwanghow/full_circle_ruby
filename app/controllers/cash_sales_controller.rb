class CashSalesController < ApplicationController
  before_filter :warn_doc_date, only: [:create, :update]

  def edit
    @cashsale = CashSale.find(params[:id])
  end

  def new
    @cashsale = CashSale.new(doc_date: Date.today)
    @cashsale.details.build
  end

  def show
    @cashsale = CashSale.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @cashsale = CashSale.new(params[:cash_sale])
    if @cashsale.save
      flash[:success] = "CashSale '##{@cashsale.id}' created successfully."
      redirect_to edit_cash_sale_path(@cashsale)
    else
      flash.now[:error] = "Failed to create CashSale."
      render :new
    end
  end

  def update
    @cashsale = CashSale.find(params[:id])
    if @cashsale.update_attributes(params[:cash_sale])
      flash[:success] = "CashSale '##{@cashsale.id}' updated successfully."
      redirect_to edit_cash_sale_path(@cashsale)
    else
      flash.now[:error] = "Failed to update CashSale."
      render :edit
    end
  end

  def new_or_edit
    if CashSale.first
      redirect_to edit_cash_sale_path(CashSale.last)
    else
      redirect_to new_cash_sale_path
    end
  end

  def new_with_template
    @cashsale = CashSale.new_like(params[:id])
    render :new
  end

  def typeahead_code
    term = "%#{params[:term].scan(/(\w)/).flatten.join('%')}%"
    render json: TaxCode.where('tax_type ilike ?', '%supply%').where('code ilike ?', term).limit(20).pluck(:code)
  end
end