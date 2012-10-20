class ProductsController < ApplicationController
  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(params[:product])
      flash[:success] = "Product '#{@product.name1}' updated successfully."
      redirect_to edit_product_path(@product)
    else
      flash.now[:error] = "Failed to updated Product."
      render :edit
    end
  end

  def new
    @product = Product.new(sale_account_name1: 'General Sales', purchase_account_name1: 'General Purchases')
  end

  def create
    @product = Product.new(params[:product])
    if @product.save
      flash[:success] = "Product '#{@product.name1}' created successfully."
      redirect_to edit_product_path(@product)
    else
      flash.now[:error] = "Failed to create Product."
      render :new
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    flash[:success] = "Successfully deleted '#{@product.name1}'."
    redirect_to product_new_or_edit_path
  end

  def new_or_edit
    if Product.first
      redirect_to edit_product_path(Product.last)
    else
      redirect_to new_product_path
    end
  end

  def typeahead_name1
    term = "%#{params[:term].scan(/(\w)/).flatten.join('%')}%"
    render json: Product.where('name1 ilike ?', term).limit(8).pluck(:name1)
  end

  def json
    render json: Product.find_by_name1(params[:name1]) || 'Not Found!'
  end

end
