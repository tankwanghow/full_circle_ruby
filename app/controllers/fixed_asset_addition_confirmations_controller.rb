class FixedAssetAdditionConfirmationsController < ApplicationController
  include SharedHelpers

  def index
    @additions = []
    if params[:assets]
      @end_date = params[:assets][:end_date].to_date
      @start_date = prev_close_date(@end_date) + 1
      FixedAsset.active.find_each do |t|
        attrs = t.unsaved_additions_attributes(@end_date.year)
        if attrs.count > 0
          @additions << t.additions.build(attrs)
        end
      end
    end
    @additions.flatten!
  end

  def create
    @addition = AssetAddition.new(params[:addition])
    if @addition.save
      flash[:success] = "Addition for #{@addition.asset.account.name1} was successfully created."
    else
      flash[:error] = "Failed to create addition."
    end
    redirect_to fixed_asset_addition_confirmations_path(assets: { end_date: @addition.entry_date })
  end

  def confirm_all
    @additions = []
    @end_date = params[:assets][:end_date].to_date
    @start_date = prev_close_date(@end_date) + 1
    FixedAsset.active.find_each do |t|
      t.fill_in_unsaved_additions_until @end_date.year
      t.save!
    end
    flash[:success] = "All Additions was successfully created."
    redirect_to fixed_asset_addition_confirmations_path(assets: { end_date: @end_date })
  end

end