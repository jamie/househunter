require 'http'

class Importer
  URI = "https://api2.realtor.ca/Listing.svc/PropertySearch_Post"

  def do_import
    1.times do |i| # loop do
      page = i + 1
      response = http.post(URI, form: query_params(page))
      # TODO: rescue "HTTP::Error: Unknown MIME type: text/html (HTTP::Error)" when credentials expire
      results = response.parse["Results"]
      pp results[0]
      exit
      break if results.empty?
      results.each do |listing_json|
        Listing.import(listing_json)
      end
    end
  end

  def http
    HTTP.cookies({
      "reese84" => "3:qVVvMMNgtdgD2g8ADf/VjQ==:L6zAU60pwU/4FB0zXo9yKo3WPOcd+axKVRTiGIdpX9/wtJ4f4HOaYRRWPsy7OvtgbruTvk9TVLDSwWKfAhY+m3TzGQtmwir/JHB7WnSA65e9vX98xkw+YC2P+J7WeSnZEBntGVLxdyFHHKGOEeYt7jJST7ApzwMQojZpAN1gTvftmlz1BkxPxR9O8WHRFS3Sk6qlzEuqnq/S7bJKACWAa+ch5VLEAfO2qmtesAGJoFXJFqGgWgBGJ/wnjz4IA+KpyMqycrDHxUzNcWwSAEpqyZS2CuTNmjiD/o+ludYyMjGavgEQ2bNtH3AQf9z/+3J29MTHp3OEphQgm9SISerBeddZX9XQwguh9/m5xro+ByrHrMBYzT0NEbNe5hfuVkrlTWOOFWBo4GuYxKRUaf7Jsaodyuw7x53zsI1iHJn27M/8KsbUWQAidFMQ2zOX0zMcDel+n6g+MgyzwMWCyjkREQ==:NFYcQXejEIxZmzrSieL2/obDtS9lBh8HhDQcs7CG52I=",
    }).headers({
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:125.0) Gecko/20100101 Firefox/125.0",
      "Referer" => "https://www.realtor.ca/",
    })
  end

  def query_params(page=1)
    {
      ZoomLevel: 12,
      LatitudeMax: 49.33,
      LongitudeMax: -123.85,
      LatitudeMin: 49.03,
      LongitudeMin: -124.08,
      Sort: "6-D",
      GeoIds: "g30_c0xzg2er",
      PropertyTypeGroupID: 1,
      TransactionTypeId: 2,
      PropertySearchTypeId: 0,
      PriceMin: 700_000,
      PriceMax: 1_300_000,
      BedRange: "2-0",
      BathRange: "2-0",
      Currency: "CAD",
      IncludeHiddenListings: false,
      RecordsPerPage: 12,
      ApplicationId: 1,
      CultureId: 1,
      Version: 7.0,
      CurrentPage: page
    }
  end
end
