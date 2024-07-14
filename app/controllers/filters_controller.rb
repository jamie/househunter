class FiltersController < ApplicationController
  UNLIMITED_PRICE = 2_250_000

  skip_forgery_protection

  before_action do
    # Update session with latest filters
    session[:min_price] = params[:min_price] if params[:min_price].present?
    session[:max_price] = params[:max_price] if params[:max_price].present?
    session[:max_age] = params[:max_age] if params[:max_age].present?

    @min_price = session[:min_price] || 0
    @max_price = session[:max_price] || UNLIMITED_PRICE

    # Bedrooms
    # Bathrooms

    # First seen? Recent update?
    @max_age = session[:max_age] || Listing::UNLIMITED_AGE

    session[:new_listings] = params[:new_listings] if params[:new_listings].present?
    @new_listings = ActiveModel::Type::Boolean.new.cast(session[:new_listings])
  end

  def index
    relation = Listing.price_range(@min_price, @max_price).filtered.recent(@max_age)
    @price_spread = relation.price_spread
    @listings = relation.all

    # Avoid issues where Firefox un-suspends the tab at /filters
    redirect_to root_url unless request.env["HTTP_TURBO_FRAME"]
  end
end
