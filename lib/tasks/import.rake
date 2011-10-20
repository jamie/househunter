class Importer
  def do_import
    require 'builder'
    require 'cgi'
    require 'json'
    require 'open-uri'

    7.times do |i|
      xml = xml_for_price(i*50000, (i+1)*50000)
      url = "http://www.realtor.ca/handlers/MapSearchHandler.ashx?xml=#{CGI::escape(xml).gsub('%2F','/')}"

      json = JSON.parse(open(url).read)
      next if json['MapSearchResults'].blank?
      json['MapSearchResults'].each do |listing_json|
        Listing.import(listing_json)
      end
    end
  end

  def xml_for_price(min, max)
    Builder::XmlMarkup.new.ListingSearchMap do |x|
      x.Culture 'en-CA'
      x.OrderBy '1'
      x.OrderDirection 'A'
      x.Culture 'en-CA'
      x.LatitudeMax '49.33'
      x.LatitudeMin '49.03'
      x.LongitudeMax '-123.85'
      x.LongitudeMin '-124.08'
      x.PriceMax max
      x.PriceMin min
      x.PropertyTypeID 300
      x.TransactionTypeID 2
      x.MinBath 2
      x.MaxBath 0
      x.MinBed 3
      x.MaxBed 0
      x.StoriesTotalMin 0
      x.StoriesTotalMax 0
    end
  end
end

namespace :mls do
  desc 'Pull available properties from realtor.ca'
  task :import => :environment do
    Importer.new.do_import
  end
end

