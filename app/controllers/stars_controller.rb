class StarsController < ApplicationController
  def index
    @listings = Listing.where(status: "remember").all
    render "listings/index"
  end
end
