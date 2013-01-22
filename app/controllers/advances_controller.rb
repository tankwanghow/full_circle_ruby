class AdvancesController < ApplicationController

  def edit
    @advance = Advance.find(params[:id])
  end

  def new
    @advance = Advance.new(doc_date: Date.today, pay_from_name1: 'Cash In Hand')
  end

  def show
    @advance = Advance.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @advance = Advance.new(params[:advance])
    if @advance.save
      flash[:success] = "Advance '##{@advance.id}' created successfully."
      redirect_to edit_advance_path(@advance)
    else
      flash.now[:error] = "Failed to create Advance."
      render :new 
    end
  end

  def update
    @advance = Advance.find(params[:id])
    if @advance.update_attributes(params[:advance])
      flash[:success] = "Advance '##{@advance.id}' updated successfully."
      redirect_to edit_advance_path(@advance)
    else
      flash.now[:error] = "Failed to update Advance."
      render :edit
    end
  end

  def new_or_edit
    if Advance.first
      redirect_to edit_advance_path(Advance.last)
    else
      redirect_to new_advance_path
    end
  end

end

