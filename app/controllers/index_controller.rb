class IndexController < ApplicationController
  before_action do
    # Update session with latest filters
    session[:min_price] = params[:min_price] if params[:min_price].present?
    session[:max_price] = params[:max_price] if params[:max_price].present?
    session[:max_age] = params[:max_age] if params[:max_age].present?

    @min_price = session[:min_price] || 0
    @max_price = session[:max_price] || ListingsController::UNLIMITED_PRICE

    # Bedrooms
    # Bathrooms

    # First seen? Recent update?
    @max_age = session[:max_age] || Listing::UNLIMITED_AGE

    session[:new_listings] = params[:new_listings] if params[:new_listings].present?
    @new_listings = ActiveModel::Type::Boolean.new.cast(session[:new_listings])
  end

  def index
    latest_import = Listing.maximum(:imported_at)
    if latest_import < 1.hours.ago
      flash.now[:notice] = "Updating properties..."
      ImportJob.perform_later
    end
  end
end
