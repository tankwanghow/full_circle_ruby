class FeedProductionsController < ApplicationController
  before_filter :fill_productions
  before_filter :upcase_params, only: [:create, :update]

  def index
  end

  def edit
    @feed_production = FeedProduction.find(params[:id])
  end

  def new
    @feed_production = FeedProduction.new(produce_date: session[:feed_productions_find][:produce_date].to_date)
  end

  def create
    @feed_production = FeedProduction.new(params[:feed_production])
    if @feed_production.save
      flash[:success] = "Feed Usage '##{@feed_production.id}' created successfully."
      redirect_to edit_feed_production_path(@feed_production)
    else
      flash.now[:error] = "Failed to create Feed Usage."
      render :new
    end
  end

  def update
    @feed_production = FeedProduction.find(params[:id])
    if @feed_production.update_attributes(params[:feed_production])
      flash[:success] = "FeedProduction '##{@feed_production.id}' updated successfully."
      redirect_to edit_feed_production_path(@feed_production)
    else
      flash.now[:error] = "Failed to update Feed Production."
      render :edit
    end
  end

  def destroy
    @feed_production = FeedProduction.find(params[:id])
    @feed_production.destroy
    flash[:success] = "Successfully deleted '#{@feed_production.lorry}'."
    render :index
  end

private

  def fill_productions
    store_param :feed_productions_find
    session[:feed_productions_find][:produce_date] ||= Date.today
    @feed_productions = FeedProduction.where(produce_date: session[:feed_productions_find][:produce_date].to_date).
                   order(:id)
  end

  def upcase_params
    params[:feed_production].each { |k,v|  v.respond_to?(:upcase) ? v.upcase! : v }
  end

end