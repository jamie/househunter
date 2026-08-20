class SearchAreasController < ApplicationController
  before_action :set_search_area, only: [:update, :destroy, :clone]

  def index
    @search_areas = SearchArea.order(:id)
  end

  # Autosaved from the manage screen (name edits, map drags, slider moves),
  # debounced client-side to one request/sec.
  def update
    if @search_area.update(search_area_params)
      head :ok
    else
      render json: {errors: @search_area.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    if SearchArea.count <= 1
      flash[:alert] = "Can't delete the last search area."
    else
      @search_area.destroy
    end

    redirect_to search_areas_path
  end

  # The only way to start a new area -- avoids hard-coding a default
  # location for a "new" form to seed itself with.
  def clone
    clone = @search_area.dup
    clone.name = "#{@search_area.name} copy"
    clone.save!

    redirect_to search_areas_path
  end

  private

  def set_search_area
    @search_area = SearchArea.find(params[:id])
  end

  def search_area_params
    params.require(:search_area).permit(:name, :lat_min, :lat_max, :lng_min, :lng_max)
  end
end
