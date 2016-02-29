class InvoicesController < ApplicationController
  before_filter :warn_doc_date, only: [:create, :update]
  
  def edit
    @invoice = Invoice.find(params[:id])
  end

  def new
    @invoice = Invoice.new(doc_date: Date.today)
    @invoice.details.build
  end

  def show
    @invoice = Invoice.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    if @invoice.save
      flash[:success] = "Invoice '##{@invoice.id}' created successfully."
      redirect_to edit_invoice_path(@invoice)
    else
      flash.now[:error] = "Failed to create Invoice."
      render :new
    end
  end

  def update
    @invoice = Invoice.find(params[:id])
    if @invoice.update_attributes(params[:invoice])
      flash[:success] = "Invoice '##{@invoice.id}' updated successfully."
      redirect_to edit_invoice_path(@invoice)
    else
      flash.now[:error] = "Failed to update Invoice."
      render :edit
    end
  end

  def new_or_edit
    if Invoice.first
      redirect_to edit_invoice_path(Invoice.last)
    else
      redirect_to new_invoice_path
    end
  end

  def typeahead_code
    term = "%#{params[:term].scan(/(\w)/).flatten.join('%')}%"
    render json: TaxCode.where('tax_type ilike ?', '%supply%').where('code ilike ?', term).limit(20).pluck(:code)
  end
end
