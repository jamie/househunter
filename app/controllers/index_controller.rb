class IndexController < ApplicationController
  def index
    latest_import = Listing.maximum(:imported_at)
    if latest_import < 1.hours.ago
      flash.now[:notice] = "Updating properties..."
      ImportJob.perform_later
    end
  end
end
