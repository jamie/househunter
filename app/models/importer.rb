require "http"

class Importer
  URI = "https://api2.realtor.ca/Listing.svc/PropertySearch_Post"

  def do_import
    page = 1
    count = Listing.count
    updated = 0
    import_time = Time.current

    loop do
      response = http.post(URI, form: query_params(page))
      # TODO: rescue "HTTP::Error: Unknown MIME type: text/html (HTTP::Error)" when credentials expire
      results = response.parse["Results"]
      break if results.empty?
      ids = results.map { |attrs| attrs["Id"] }
      listings = Listing.where(external_id: ids).index_by(&:external_id)
      results.each do |attrs|
        listing = listings[attrs["Id"].to_i] || Listing.new(external_id: attrs["Id"])

        listing.attributes = {
          lat: attrs.dig("Property", "Address", "Latitude"),
          lng: attrs.dig("Property", "Address", "Longitude"),
          address: attrs.dig("Property", "Address", "AddressText").to_s.split("|").first,
          price: attrs.dig("Property", "Price").to_s.gsub(/[^0-9]/, "").to_i,
          bedrooms: attrs.dig("Building", "Bedrooms"),
          bathrooms: attrs.dig("Building", "BathroomTotal"),
          external_url: "https://www.realtor.ca#{attrs.dig("RelativeURLEn")}",
          tooltip_photo: attrs.dig("Property", "Photo", 0, "MedResPath")
        }
        if listing.changed?
          listing.imported_at = import_time
          listing.save
          listing.imports.create(json: attrs)
          print "."
          updated += 1
        end
        listing.touch(:updated_at)
      end
      page += 1
      print "/"
    end
    created = Listing.count - count
    puts
    `say "imported #{updated} listings, #{created} new"`
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
      LatitudeMax: 49.33,
      LongitudeMax: -123.85,
      LatitudeMin: 49.03,
      LongitudeMin: -124.08,
      PropertyTypeGroupID: 1, # Residential
      TransactionTypeId: 2, # For Sale (not rent)
      PropertySearchTypeId: 0,
      RecordsPerPage: 50,
      ApplicationId: 1,
      CultureId: 1,
      Version: 7.0,
      CurrentPage: page
    }
  end
end
