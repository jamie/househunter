class ListingsController < ApplicationController
  def index
    relation = Listing.max_price(nil).filtered.recent
    @price_spread = relation.price_spread
    @listings = relation.all
  end
end
