class CurrentSearchAreaController < ApplicationController
  skip_forgery_protection

  before_action do
    ids = SearchArea.order(:id).pluck(:id)

    if params[:direction].present? && ids.any?
      position = ids.index(current_search_area&.id) || 0
      position = case params[:direction]
      when "next" then (position + 1) % ids.size
      when "prev" then (position - 1) % ids.size
      else position
      end
      session[:search_area_id] = ids[position]
    end

    @search_area = current_search_area
  end

  def index
    # Avoid issues where Firefox un-suspends the tab at /current_search_area
    redirect_to root_url unless request.env["HTTP_TURBO_FRAME"]
  end
end
