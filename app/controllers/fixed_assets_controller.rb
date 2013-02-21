class FixedAssetsController < ApplicationController
  before_filter :load_account, only: [:create, :new]

  def new
    @asset = FixedAsset.new(account: @account)
  end

  def edit
    @asset = FixedAsset.find(params[:id])
    @asset.fill_in_unsaved_additions_until
  end

  def create
    @asset = FixedAsset.new(params[:fixed_asset])
    @asset.account = @account
    if @asset.save
      flash[:success] = 'FixedAsset was successfully created.'
      redirect_to edit_fixed_asset_path(@asset)
    else
      flash[:error] = "Failed to create asset."
      render :new
    end
  end

  def update
    @asset = FixedAsset.find(params[:id])
    if @asset.update_attributes(params[:fixed_asset])
      flash[:success] = 'FixedAsset was successfully updated.'
      redirect_to edit_fixed_asset_path(@asset)
    else
      flash[:error] = "Failed to update asset."
      render :edit
    end
  end

  def destroy
    @asset = FixedAsset.find(params[:id])
    @asset.destroy
    flash[:success] = 'FixedAsset was successfully deleted.'
    redirect_to edit_account_path(@asset.account)
  end

private

  def load_account
    if params[:fixed_asset][:account_id]
      @account = Account.find(params[:fixed_asset][:account_id])
    end
  end
end
