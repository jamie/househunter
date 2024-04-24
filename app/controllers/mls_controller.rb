class MlsController < ApplicationController
  def show
    listing = Listing.find(params[:id])
    out = URI.open(listing.url).read
    out.sub!("<SCRIPT LANGUAGE='Javascript'>if (window != top) top.location.href = location.href;</SCRIPT>", "")
    out.sub!('"REALTOR">', '"REALTOR"><base href="http://www.realtor.ca/">')
    render text: out
  end
end
