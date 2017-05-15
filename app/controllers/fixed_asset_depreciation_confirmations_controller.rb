class FixedAssetDepreciationConfirmationsController < ApplicationController
  include SharedHelpers

  def index
    @depreciations = []
    if params[:assets]
      @end_date = params[:assets][:end_date].to_date
      @start_date = prev_close_date(@end_date) + 1
      AssetAddition.active.order(:fixed_asset_id, :entry_date, :id).each do |t|
        attrs = t.annual_depreciation_for(@end_date.year)
        if attrs.count > 0
          @depreciations << t.depreciations.build(attrs)
        end
      end
    end
    @depreciations.flatten!
  end

  def create
    @depreciation = AssetDepreciation.new(params[:depreciation])
    if @depreciation.save
      flash[:success] = "Depreciation for #{@depreciation.asset_addition.asset.account.name1} was successfully created."
    else
      flash[:error] = "Failed to create depreciation."
    end
    redirect_to fixed_asset_depreciation_confirmations_path(assets: { end_date: @depreciation.entry_date })
  end

  def confirm_all
    @additions = []
    @end_date = params[:assets][:end_date].to_date
    AssetAddition.active.find_each do |t|
      t.generate_annual_depreciation(@end_date.year)
      t.save!
    end
    flash[:success] = "All Depreciations was successfully created."
    redirect_to fixed_asset_depreciation_confirmations_path(assets: { end_date: @end_date })
  end

end