class ListingsController < ApplicationController
  def index
    @price_spread = Listing.price_spread
    @listings = Listing.recent.filtered.all
  end
end
