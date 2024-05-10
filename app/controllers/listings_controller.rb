class ListingsController < ApplicationController
  UNLIMITED_PRICE = 2_250_000

  skip_forgery_protection

  before_action do
    # Update session with latest search queries
    session[:min_price] = params[:min_price] if params[:min_price].present?
    session[:max_price] = params[:max_price] if params[:max_price].present?

    @min_price = session[:min_price] || 0
    @max_price = session[:max_price] || UNLIMITED_PRICE

    session[:new_listings] = params[:new_listings] if params[:new_listings].present?
    @new_listings = ActiveModel::Type::Boolean.new.cast(session[:new_listings])
  end

  def index
    @latest_import = Listing.maximum(:imported_at)

    respond_to do |format|
      format.html {
        if @latest_import < 8.hours.ago
          flash.now[:notice] = "Updating properties..."
          ImportJob.perform_later
        end
      }
      format.js {
        relation = Listing.price_range(@min_price, @max_price).filtered.recent(@new_listings ? 5 : 60)
        @price_spread = relation.price_spread
        @listings = relation.all
      }
    end
  end
end
