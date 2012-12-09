class AssetAdditionsController < ApplicationController

  def edit
    @addition = AssetAddition.find(params[:id])
    @addition.generate_annual_depreciation Date.today.year - 1
    render 'fixed_assets/additions'
  end

  def update
    @addition = AssetAddition.find(params[:id])
    if @addition.update_attributes(params[:asset_addition])
      flash[:success] = 'Additions was successfully updated.'
      redirect_to edit_asset_addition_path @addition
    else
      flash[:error] = "Failed to update Additions."
      render 'fixed_assets/additions'
    end
  end

end
