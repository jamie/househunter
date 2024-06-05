class ListingsController < ApplicationController
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

    @max_age = session[:max_age] || Listing::UNLIMITED_AGE
  end

  def index
    respond_to do |format|
      format.js {
        relation = Listing.price_range(@min_price, @max_price).filtered.fresh.recent(@max_age).or(
          Listing.starred.fresh
        )
        @price_spread = relation.price_spread
        @listings = relation.all
      }
    end
  end

  def show
    # Map popup
    listing = Listing.find(params[:id])
    render locals: {listing:}, layout: false
  end
end
