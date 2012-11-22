class CreditNotesController < ApplicationController
  def edit
    @credit_note = CreditNote.find(params[:id])
  end

  def new
    @credit_note = CreditNote.new(doc_date: Date.today)
    @credit_note.particulars.build
  end

  def show
    @credit_note = CreditNote.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @credit_note = CreditNote.new(params[:credit_note])
    if @credit_note.save
      flash[:success] = "CreditNote '##{@credit_note.id}' created successfully."
      redirect_to edit_credit_note_path(@credit_note)
    else
      flash.now[:error] = "Failed to create CreditNote."
      render :new
    end
  end

  def update
    @credit_note = CreditNote.find(params[:id])
    if @credit_note.update_attributes(params[:credit_note])
      flash[:success] = "CreditNote '##{@credit_note.id}' updated successfully."
      redirect_to edit_credit_note_path(@credit_note)
    else
      flash.now[:error] = "Failed to update CreditNote."
      render :edit
    end
  end

  def new_or_edit
    if CreditNote.first
      redirect_to edit_credit_note_path(CreditNote.last)
    else
      redirect_to new_credit_note_path
    end
  end
end
