class FlocksController < ApplicationController

  def edit
    @flock = Flock.find(params[:id])
  end

  def new
    @flock = Flock.new(dob: Date.today)
  end

  def create
    @flock = Flock.new(params[:flock])
    if @flock.save
      flash[:success] = "Flock '##{@flock.id}' created successfully."
      redirect_to edit_flock_path(@flock)
    else
      flash.now[:error] = "Failed to create Flock."
      render :new 
    end
  end

  def update
    @flock = Flock.find(params[:id])
    if @flock.update_attributes(params[:flock])
      flash[:success] = "Flock '##{@flock.id}' updated successfully."
      redirect_to edit_flock_path(@flock)
    else
      flash.now[:error] = "Failed to update Flock."
      render :edit
    end
  end

  def new_or_edit
    if Flock.first
      redirect_to edit_flock_path(Flock.last)
    else
      redirect_to new_flock_path
    end
  end

  def typeahead_breed
    render json: typeahead_result(params[:term], "breed", Flock)
  end

  def info
    house = House.find_by_house_no(params[:house])
    if house
      flock = house.flock_at(params[:harvest_date].to_date)
      if flock
        render json: { flock_info: flock.flock_info, flock_id: flock.id }
      else
        render json: { flock_info: 'No Chicken!', flock_id: -9 }
      end
    end
  end

end

