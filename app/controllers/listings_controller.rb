class ListingsController < ApplicationController

  def index
    @listings = Listing.order(:last_import).all.reverse
  end

end
