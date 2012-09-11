class ParticularTypesController < ApplicationController
  def edit
    @particular_type = ParticularType.find(params[:id])
  end

  def update
    @particular_type = ParticularType.find(params[:id])
    if @particular_type.update_attributes(params[:particular_type])
      flash[:success] = "Particular Type '#{@particular_type.name}' updated successfully."
      redirect_to edit_particular_type_path(@particular_type)
    else
      flash.now[:error] = "Failed to updated Particular Type."
      render :edit
    end
  end

  def new
    @particular_type = ParticularType.new
  end

  def create
    @particular_type = ParticularType.new(params[:particular_type])
    if @particular_type.save
      flash[:success] = "Particular Type '#{@particular_type.name}' created successfully."
      redirect_to edit_particular_type_path(@particular_type)
    else
      flash.now[:error] = "Failed to create Particular Type."
      render :new
    end
  end

  def destroy
    @particular_type = ParticularType.find(params[:id])
    @particular_type.destroy
    flash[:success] = "Successfully deleted '#{@particular_type.name}'."
    redirect_to particular_type_new_or_edit_path
  end

  def new_or_edit
    if ParticularType.first
      flash.keep
      redirect_to edit_particular_type_path(ParticularType.last)
    else
      redirect_to new_particular_type_path
    end
  end
end
