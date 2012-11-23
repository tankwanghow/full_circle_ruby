class DebitNotesController < ApplicationController
  def edit
    @debit_note = DebitNote.find(params[:id])
  end

  def new
    @debit_note = DebitNote.new(doc_date: Date.today)
    @debit_note.particulars.build
  end

  def show
    @debit_note = DebitNote.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @debit_note = DebitNote.new(params[:debit_note])
    if @debit_note.save
      flash[:success] = "DebitNote '##{@debit_note.id}' created successfully."
      redirect_to edit_debit_note_path(@debit_note)
    else
      flash.now[:error] = "Failed to create DebitNote."
      render :new
    end
  end

  def update
    @debit_note = DebitNote.find(params[:id])
    if @debit_note.update_attributes(params[:debit_note])
      flash[:success] = "DebitNote '##{@debit_note.id}' updated successfully."
      redirect_to edit_debit_note_path(@debit_note)
    else
      flash.now[:error] = "Failed to update DebitNote."
      render :edit
    end
  end

  def new_or_edit
    if DebitNote.first
      redirect_to edit_debit_note_path(DebitNote.last)
    else
      redirect_to new_debit_note_path
    end
  end
end
