class ListingsController < ApplicationController
  skip_forgery_protection

  def index
    relation = Listing.min_price(params[:min_price]).max_price(params[:max_price]).filtered.recent
    @price_spread = relation.price_spread
    @listings = relation.all

    respond_to do |format|
      format.html
      format.js
    end
  end
end
