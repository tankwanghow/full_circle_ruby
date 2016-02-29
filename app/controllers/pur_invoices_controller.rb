class PurInvoicesController < ApplicationController
  def edit
    @invoice = PurInvoice.find(params[:id])
  end

  def new
    @invoice = PurInvoice.new(doc_date: Date.today)
    @invoice.details.build
  end

  def create
    @invoice = PurInvoice.new(params[:pur_invoice])
    if @invoice.save
      flash[:success] = "Purchase Invoice '##{@invoice.id}' created successfully."
      redirect_to edit_pur_invoice_path(@invoice)
    else
      flash.now[:error] = "Failed to create Purchase Invoice."
      render :new
    end
  end

  def update
    @invoice = PurInvoice.find(params[:id])
    if @invoice.update_attributes(params[:pur_invoice])
      flash[:success] = "Purchase Invoice '##{@invoice.id}' updated successfully."
      redirect_to edit_pur_invoice_path(@invoice)
    else
      flash.now[:error] = "Failed to update Purchase Invoice."
      render :edit
    end
  end

  def new_or_edit
    if PurInvoice.first
      redirect_to edit_pur_invoice_path(PurInvoice.last)
    else
      redirect_to new_pur_invoice_path
    end
  end

  def typeahead_code
    term = "%#{params[:term].scan(/(\w)/).flatten.join('%')}%"
    render json: TaxCode.where('tax_type ilike ?', '%purchase%').where('code ilike ?', term).limit(20).pluck(:code)
  end
end
