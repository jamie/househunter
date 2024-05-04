class ListingsController < ApplicationController
  UNLIMITED_PRICE = 2_250_000

  skip_forgery_protection

  def index
    ImportJob.perform_later if Listing.maximum(:created_at) < 8.hours.ago
    session[:min_price] = params[:min_price] if params[:min_price].present?
    session[:max_price] = params[:max_price] if params[:max_price].present?

    @min_price = session[:min_price] || 0
    @max_price = session[:max_price] || UNLIMITED_PRICE

    relation = Listing.min_price(@min_price).max_price(@max_price).filtered.recent
    @price_spread = relation.price_spread
    @listings = relation.all

    respond_to do |format|
      format.html
      format.js
    end
  end
end
