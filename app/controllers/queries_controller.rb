class QueriesController < ApplicationController
  before_filter :allow_admin_only

  def index
    @queries = Query.where('1=1').order(:name)
  end

  def edit
    @query = Query.find(params[:id])
  end

  def new
    @query = Query.new
  end

  def create
    @query = Query.new(params[:query])
    if @query.save
      flash[:success] = "Query '##{@query.id}' created successfully."
      redirect_to edit_query_path(@query)
    else
      flash.now[:error] = "Failed to create Query."
      render :new 
    end
  end

  def update
    if params[:submit] == 'Save'
      update_query
    elsif params[:submit] == 'Execute'
      run_query
    elsif params[:submit] == "CSV"
      request.format = :csv
      run_query
    end
  end

  def new_or_edit
    if Query.first
      redirect_to edit_query_path(Query.last)
    else
      redirect_to new_query_path
    end
  end

private

  def update_query
    @query = Query.find(params[:id])
    if @query.update_attributes(params[:query])
      flash[:success] = "Query '##{@query.id}' updated successfully."
      redirect_to edit_query_path(@query)
    else
      flash.now[:error] = "Failed to update Query."
      render :edit
    end
  end

  def run_query
    @query = Query.find(params[:id])
    @query.name = params[:query][:name]
    @query.query = params[:query][:query]
    begin
      @results = @query.run
    rescue ActiveRecord::StatementInvalid => e
      flash[:error] = e.message
    end
    respond_to do |t| 
      t.html { render :edit }
      t.csv  { render :edit, formats: :csv, handler: :rb }
    end
  end

end