class AllController < ApplicationController
  def index
    @listings = Listing.recent.all
    render "listings/index"
  end
end
