class EmployeesController < ApplicationController
  def edit
    @employee = Employee.find(params[:id])
  end

  def new
    @employee = Employee.new_with_salary_types
  end

  def create
    @employee = Employee.new(params[:employee])
    if @employee.save
      flash[:success] = "Employee '##{@employee.name}' created successfully."
      redirect_to edit_employee_path(@employee)
    else
      flash.now[:error] = "Failed to create Employee."
      render :new
    end
  end

  def update
    @employee = Employee.find(params[:id])
    if @employee.update_attributes(params[:employee])
      flash[:success] = "Employee '##{@employee.name}' updated successfully."
      redirect_to edit_employee_path(@employee)
    else
      flash.now[:error] = "Failed to update Employee."
      render :edit
    end
  end

  def new_or_edit
    if Employee.first
      redirect_to edit_employee_path(Employee.last)
    else
      redirect_to new_employee_path
    end
  end

  def new_with_template
    @employee = Employee.new_like(params[:id])
    render :new
  end

  def typeahead_name
    term = "%#{params[:term].scan(/(\w)/).flatten.join('%')}%"
    render json: Employee.where("name ilike ?", term).limit(8).order(:name).pluck(:name)
  end
end
