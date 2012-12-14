class SalaryNotesController < ApplicationController

  def edit
    @salary_note = SalaryNote.find(params[:id])
  end

  def new
    @salary_note = SalaryNote.new(doc_date: Date.today)
  end

  def show
    @salary_note = SalaryNote.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @salary_note = SalaryNote.new(params[:salary_note])
    if @salary_note.save
      flash[:success] = "SalaryNote '##{@salary_note.id}' created successfully."
      redirect_to edit_salary_note_path(@salary_note)
    else
      flash.now[:error] = "Failed to create SalaryNote."
      render :new 
    end
  end

  def update
    @salary_note = SalaryNote.find(params[:id])
    if @salary_note.update_attributes(params[:salary_note])
      flash[:success] = "SalaryNote '##{@salary_note.id}' updated successfully."
      redirect_to edit_salary_note_path(@salary_note)
    else
      flash.now[:error] = "Failed to update SalaryNote."
      render :edit
    end
  end

  def new_or_edit
    if SalaryNote.first
      redirect_to edit_salary_note_path(SalaryNote.last)
    else
      redirect_to new_salary_note_path
    end
  end

end