class FeedUsagesController < ApplicationController
  before_filter :fill_usages
  before_filter :upcase_params, only: [:create, :update]

  def index
  end

  def edit
    @feed_usage = FeedUsage.find(params[:id])
  end

  def new
    @feed_usage = FeedUsage.new(usage_date: session[:feed_usages_find][:usage_date].to_date)
  end

  def create
    @feed_usage = FeedUsage.new(params[:feed_usage])
    if @feed_usage.save
      flash[:success] = "Feed Usage '##{@feed_usage.id}' created successfully."
      redirect_to edit_feed_usage_path(@feed_usage)
    else
      flash.now[:error] = "Failed to create Feed Usage."
      render :new
    end
  end

  def update
    @feed_usage = FeedUsage.find(params[:id])
    if @feed_usage.update_attributes(params[:feed_usage])
      flash[:success] = "FeedUsage '##{@feed_usage.id}' updated successfully."
      redirect_to edit_feed_usage_path(@feed_usage)
    else
      flash.now[:error] = "Failed to update Feed Usage."
      render :edit
    end
  end

  def destroy
    @feed_usage = FeedUsage.find(params[:id])
    @feed_usage.destroy
    flash[:success] = "Successfully deleted '#{@feed_usage.lorry}'."
    render :index
  end

private

  def fill_usages
    store_param :feed_usages_find
    session[:feed_usages_find][:usage_date] ||= Date.today
    @feed_usages = FeedUsage.where(usage_date: session[:feed_usages_find][:usage_date].to_date).
                   order('id DESC')
  end

  def upcase_params
    params[:feed_usage].each { |k,v|  v.respond_to?(:upcase) ? v.upcase! : v }
  end

end