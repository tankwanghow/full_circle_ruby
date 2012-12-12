class SalaryTypesController < ApplicationController
  def edit
    @salary_type = SalaryType.find(params[:id])
  end

  def new
    @salary_type = SalaryType.new
  end

  def show
    @salary_type = SalaryType.find(params[:id])
  end

  def create
    @salary_type = SalaryType.new(params[:salary_type])
    if @salary_type.save
      flash[:success] = "SalaryType '##{@salary_type.name}' created successfully."
      redirect_to edit_salary_type_path(@salary_type)
    else
      flash.now[:error] = "Failed to create SalaryType."
      render :new
    end
  end

  def update
    @salary_type = SalaryType.find(params[:id])
    if @salary_type.update_attributes(params[:salary_type])
      flash[:success] = "SalaryType '##{@salary_type.name}' updated successfully."
      redirect_to edit_salary_type_path(@salary_type)
    else
      flash.now[:error] = "Failed to update SalaryType."
      render :edit
    end
  end

  def new_or_edit
    if SalaryType.first
      redirect_to edit_salary_type_path(SalaryType.last)
    else
      redirect_to new_salary_type_path
    end
  end
end
