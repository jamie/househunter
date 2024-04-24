require "http"

class Importer
  URI = "https://api2.realtor.ca/Listing.svc/PropertySearch_Post"
  IGNORED_ATTRS = %w[Individual Business TimeOnRealtor Tags]
  UNIMPORTANT_ATTRS = IGNORED_ATTRS + %w[HasNewImageUpdate]

  def do_import
    page = 1
    loop do
      response = http.post(URI, form: query_params(page))
      # TODO: rescue "HTTP::Error: Unknown MIME type: text/html (HTTP::Error)" when credentials expire
      results = response.parse["Results"]
      break if results.empty?
      results.each do |listing_json|
        import_listing(listing_json)
      end
      page += 1
    end
    puts
  end

  def http
    HTTP.cookies({
      "reese84" => "3:qVVvMMNgtdgD2g8ADf/VjQ==:L6zAU60pwU/4FB0zXo9yKo3WPOcd+axKVRTiGIdpX9/wtJ4f4HOaYRRWPsy7OvtgbruTvk9TVLDSwWKfAhY+m3TzGQtmwir/JHB7WnSA65e9vX98xkw+YC2P+J7WeSnZEBntGVLxdyFHHKGOEeYt7jJST7ApzwMQojZpAN1gTvftmlz1BkxPxR9O8WHRFS3Sk6qlzEuqnq/S7bJKACWAa+ch5VLEAfO2qmtesAGJoFXJFqGgWgBGJ/wnjz4IA+KpyMqycrDHxUzNcWwSAEpqyZS2CuTNmjiD/o+ludYyMjGavgEQ2bNtH3AQf9z/+3J29MTHp3OEphQgm9SISerBeddZX9XQwguh9/m5xro+ByrHrMBYzT0NEbNe5hfuVkrlTWOOFWBo4GuYxKRUaf7Jsaodyuw7x53zsI1iHJn27M/8KsbUWQAidFMQ2zOX0zMcDel+n6g+MgyzwMWCyjkREQ==:NFYcQXejEIxZmzrSieL2/obDtS9lBh8HhDQcs7CG52I="
    }).headers({
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:125.0) Gecko/20100101 Firefox/125.0",
      "Referer" => "https://www.realtor.ca/"
    })
  end

  def query_params(page = 1)
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

  def import_listing(attrs)
    listing = Listing.find_or_create_by(external_id: attrs["Id"])

    return if listing.last_imported == attrs
    return if (listing.last_imported.diff(attrs).keys - IGNORED_ATTRS).empty?

    if listing.json.blank?
      print "*"
      listing.json = attrs.to_json
      listing.imported_at = Time.now
    else
      print "."
      pp(listing.last_imported.diff(attrs))
      pp(attrs.diff(listing.last_imported))
      exit
      listing.json = listing.json + "\n" + attrs.to_json
      if !((listing.last_imported.diff attrs).keys - UNIMPORTANT_ATTRS).empty?
        listing.imported_at = Time.now
      end
    end

    last = listing.last_imported
    listing.lat = last.dig("Property", "Address", "Latitude")
    listing.lng = last.dig("Property", "Address", "Longitude")
    listing.address = last.dig("Property", "Address", "AddressText").split("|").first
    listing.price = last.dig("Property", "Price").gsub(/[^0-9]/, "").to_i
    listing.save
  end
end
