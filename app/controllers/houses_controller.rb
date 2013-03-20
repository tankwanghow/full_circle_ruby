class HousesController < ApplicationController

  def edit
    @house = House.find(params[:id])
  end

  def new
    @house = House.new
  end

  def create
    @house = House.new(params[:house])
    if @house.save
      flash[:success] = "House '##{@house.id}' created successfully."
      redirect_to edit_house_path(@house)
    else
      flash.now[:error] = "Failed to create House."
      render :new 
    end
  end

  def update
    @house = House.find(params[:id])
    if @house.update_attributes(params[:house])
      flash[:success] = "House '##{@house.id}' updated successfully."
      redirect_to edit_house_path(@house)
    else
      flash.now[:error] = "Failed to update House."
      render :edit
    end
  end

  def new_or_edit
    if House.first
      redirect_to edit_house_path(House.last)
    else
      redirect_to new_house_path
    end
  end

end

