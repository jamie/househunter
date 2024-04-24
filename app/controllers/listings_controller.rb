class ListingsController < ApplicationController
  def index
    @listings = Listing.recent.filtered.all
  end
end
