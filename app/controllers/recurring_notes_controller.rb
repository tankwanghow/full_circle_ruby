class RecurringNotesController < ApplicationController
  before_filter :warn_doc_date, only: [:create, :update]

  def edit
    @recurring_note = RecurringNote.find(params[:id])
  end

  def new
    @recurring_note = RecurringNote.new(doc_date: Date.today)
  end

  def show
    @recurring_note = RecurringNote.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @recurring_note = RecurringNote.new(params[:recurring_note])
    if @recurring_note.save
      flash[:success] = "RecurringNote '##{@recurring_note.id}' created successfully."
      redirect_to edit_recurring_note_path(@recurring_note)
    else
      flash.now[:error] = "Failed to create RecurringNote."
      render :new 
    end
  end

  def update
    @recurring_note = RecurringNote.find(params[:id])
    if @recurring_note.update_attributes(params[:recurring_note])
      flash[:success] = "RecurringNote '##{@recurring_note.id}' updated successfully."
      redirect_to edit_recurring_note_path(@recurring_note)
    else
      flash.now[:error] = "Failed to update RecurringNote."
      render :edit
    end
  end

  def new_or_edit
    if RecurringNote.first
      redirect_to edit_recurring_note_path(RecurringNote.last)
    else
      redirect_to new_recurring_note_path
    end
  end

end