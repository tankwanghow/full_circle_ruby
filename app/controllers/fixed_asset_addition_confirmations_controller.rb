class FixedAssetAdditionConfirmationsController < ApplicationController
  include SharedHelpers

  def new
  end

  def index
    @additions = []
    @end_date = params[:assets][:end_date].to_date
    @start_date = prev_close_date(@end_date) + 1
    FixedAsset.find_each do |t|
      attrs = t.unsaved_additions_attributes(@end_date.year)
      if attrs.count > 0
        @additions << t.additions.build(attrs)
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

end