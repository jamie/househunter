require "./setup"

require "sinatra"
require "cgi"
require "open-uri"

get "/all" do
  @listings = Listing.recent.all
  erb :index
end

get "/remembered" do
  @listings = Listing.where(status: "remember").all
  erb :index
end

get "/listing/:id/mls" do
  listing = Listing.find(params[:id])
  out = URI.open(listing.url).read
  out.sub!("<SCRIPT LANGUAGE='Javascript'>if (window != top) top.location.href = location.href;</SCRIPT>", "")
  out.sub!('"REALTOR">', '"REALTOR"><base href="http://www.realtor.ca/">')
  out
end

post "/listing/:id/:status" do
  pass unless %w[new ignore remember].include? params[:status]
  listing = Listing.find(params[:id])
  listing.status = params[:status]
  listing.save
end
