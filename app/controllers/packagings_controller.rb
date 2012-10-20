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

  def typeahead_product_package_name
    render json: ProductPackaging.pack_qty_names(params[:product_id], params[:term])
  end

  def typeahead_name
    term = "%#{params[:term].scan(/(\w)/).flatten.join('%')}%"
    render json: Packaging.where('name ilike ?', term).limit(8).pluck(:name)
  end

  def json
    render json: ProductPackaging.find_product_package(params[:product_id], params[:name])
  end  

end
