class ApplicationController < ActionController::Base
  private

  # The area shown on the map and cycled through by the top-center panel.
  # Falls back to the first area (by id) once the session's pick is gone
  # (deleted, or never set).
  def current_search_area
    SearchArea.find_by(id: session[:search_area_id]) || SearchArea.order(:id).first
  end
end
