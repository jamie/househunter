namespace :mls do
  desc 'Pull available properties from realtor.ca'
  task :import => :environment do
    require 'builder'
    require 'cgi'
    require 'json'
    require 'open-uri'

    xml = Builder::XmlMarkup.new.ListingSearchMap do |x|
      x.Culture 'en-CA'
      x.OrderBy '1'
      x.OrderDirection 'A'
      x.Culture 'en-CA'
      x.LatitudeMax '49.21580303797483'
      x.LatitudeMin '49.11253463153366'
      x.LongitudeMax '-123.86020660400392'
      x.LongitudeMin '-124.01298522949217'
      x.PriceMax 0
      x.PriceMin 0
      x.PropertyTypeID 300
      x.TransactionTypeID 2
      x.MinBath 2
      x.MaxBath 0
      x.MinBed 3
      x.MaxBed 0
      x.StoriesTotalMin 0
      x.StoriesTotalMax 0
    end

    url = "http://www.realtor.ca/handlers/MapSearchHandler.ashx?xml=#{CGI::escape(xml).gsub('%2F','/')}"

    json = JSON.parse(open(url).read)
    if json['MapSearchResults'].empty?
      puts 'No Results'
    else
      json['MapSearchResults'].each do |listing_json|
        Listing.import(listing_json)
      end
      puts
    end
  end
end

