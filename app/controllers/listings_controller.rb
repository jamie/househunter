class ListingsController < ApplicationController
  UNLIMITED_PRICE = 2_250_000

  skip_forgery_protection

  before_action :import_listings, only: :index

  before_action do
    session[:min_price] = params[:min_price] if params[:min_price].present?
    session[:max_price] = params[:max_price] if params[:max_price].present?

    @min_price = session[:min_price] || 0
    @max_price = session[:max_price] || UNLIMITED_PRICE
  end

  before_action do
    session[:new_listings] = params[:new_listings] if params[:new_listings].present?
    @new_listings = ActiveModel::Type::Boolean.new.cast(session[:new_listings])
  end

  def index
    relation = Listing.price_range(@min_price, @max_price).filtered.recent(@new_listings ? 5 : 60)
    @price_spread = relation.price_spread
    @listings = relation.all

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def import_listings
    return if Listing.maximum(:created_at) > 8.hours.ago

    flash.now[:notice] = "Updating properties..."
    ImportJob.perform_later
  end
end
