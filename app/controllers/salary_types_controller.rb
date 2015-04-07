class SalaryTypesController < ApplicationController
  def edit
    @salary_type = SalaryType.find(params[:id])
  end

  def new
    @salary_type = SalaryType.new
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
    admin_lock_check @salary_type
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

  def typeahead_name
    render json: typeahead_result(params[:term], "name", SalaryType)
  end

  def json
    p = SalaryType.find_by_name(params[:name])
    if p
      render json: p.attributes
    else
      render json: 'Not Found!'
    end
  end

  def typeahead_addition_name
    term = "%#{params[:term].scan(/(\w)/).flatten.join('%')}%"
    render json: SalaryType.addition.where("name ilike ?", term).limit(8).pluck(:name)
  end

  def typeahead_deduction_name
    term = "%#{params[:term].scan(/(\w)/).flatten.join('%')}%"
    render json: SalaryType.deduction.where("name ilike ?", term).limit(8).pluck(:name)
  end

  def typeahead_contribution_name
    term = "%#{params[:term].scan(/(\w)/).flatten.join('%')}%"
    render json: SalaryType.contribution.where("name ilike ?", term).limit(8).pluck(:name)
  end
end
