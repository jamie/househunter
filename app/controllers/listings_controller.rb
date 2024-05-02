class ListingsController < ApplicationController
  skip_forgery_protection

  def index
    ImportJob.perform_later if Listing.maximum(:created_at) < 8.hours.ago

    relation = Listing.min_price(params[:min_price]).max_price(params[:max_price]).filtered.recent
    @price_spread = relation.price_spread
    @listings = relation.all

    respond_to do |format|
      format.html
      format.js
    end
  end
end
