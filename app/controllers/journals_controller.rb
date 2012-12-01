class JournalsController < ApplicationController
  def edit
    @journal = Journal.find(params[:id])
  end

  def new
    @journal = Journal.new(doc_date: Date.today)
    @journal.transactions.build
  end

  def show
    @journal = Journal.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @journal = Journal.new(params[:journal])
    if @journal.save
      flash[:success] = "Journal '##{@journal.id}' created successfully."
      redirect_to edit_journal_path(@journal)
    else
      flash.now[:error] = "Failed to create Journal."
      render :new
    end
  end

  def update
    @journal = Journal.find(params[:id])
    if @journal.update_attributes(params[:journal])
      flash[:success] = "Journal '##{@journal.id}' updated successfully."
      redirect_to edit_journal_path(@journal)
    else
      flash.now[:error] = "Failed to update Journal."
      render :edit
    end
  end

  def new_or_edit
    if Journal.first
      redirect_to edit_journal_path(Journal.last)
    else
      redirect_to new_journal_path
    end
  end
end
