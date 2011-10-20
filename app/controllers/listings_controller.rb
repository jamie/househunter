class ListingsController < ApplicationController

  def index
    @listings = Listing.where("last_import > ?", 5.days.ago).order(:last_import).all.reverse
  end

end
