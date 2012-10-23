class AddressesController < ApplicationController
  before_filter :load_parent, only: [:create, :new]

  def new
    @address = Address.new(addressable: @parent, country: 'Malaysia')
  end

  def edit
    @address = Address.find(params[:id])
  end

  def create
    @address = Address.new(params[:address])
    @address.addressable = @parent
    if @address.save
      flash[:success] = 'Address was successfully created.'
      redirect_to edit_polymorphic_path @parent
    else
      flash[:error] = "Failed to create address."
      render :new
    end
  end

  def update
    @address = Address.find(params[:id])
    if @address.update_attributes(params[:address])
      flash[:success] = 'Address was successfully updated.'
      redirect_to edit_polymorphic_path @address.addressable
    else
      flash[:error] = "Failed to update address."
      render :edit
    end
  end

  def destroy
    @address = Address.find(params[:id])
    @address.destroy
    flash[:success] = 'Address was successfully deleted.'
    redirect_to edit_polymorphic_path @address.addressable
  end

private

  def load_parent
    if params[:address][:addressable_id] and params[:address][:addressable_type]
      @parent = params[:address][:addressable_type].constantize.find(params[:address][:addressable_id])
    end
  end
end
