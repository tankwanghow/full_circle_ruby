class PackagingsController < ApplicationController
  def edit
    @packaging = Packaging.find(params[:id])
  end

  def update
    @packaging = Packaging.find(params[:id])
    if @packaging.update_attributes(params[:packaging])
      flash[:success] = "Packaging'#{@packaging.name}' updated successfully."
      redirect_to edit_packaging_path(@packaging)
    else
      flash.now[:error] = "Failed to updated Packaging."
      render :edit
    end
  end

  def new
    @packaging = Packaging.new
  end

  def create
    @packaging = Packaging.new(params[:packaging])
    if @packaging.save
      flash[:success] = "Packaging'#{@packaging.name}' created successfully."
      redirect_to edit_packaging_path(@packaging)
    else
      flash.now[:error] = "Failed to create Packaging."
      render :new
    end
  end

  def destroy
    @packaging = Packaging.find(params[:id])
    @packaging.destroy
    flash[:success] = "Successfully deleted '#{@packaging.name}'."
    redirect_to product_new_or_edit_path
  end

  def new_or_edit
    if Packaging.first
      redirect_to edit_packaging_path(Packaging.last)
    else
      redirect_to new_packaging_path
    end
  end

end
