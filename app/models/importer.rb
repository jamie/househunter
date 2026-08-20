require "json"
require "open3"

class Importer
  # realtor.ca is behind Cloudflare bot management that fingerprints the
  # TLS/HTTP2 handshake, so the http gem can't reach it -- every request comes
  # back as a 403 block page regardless of what cookies we send. lib/realtor_fetch.py
  # replays a real Firefox handshake and streams the listings back as NDJSON;
  # see that file for the full picture. Everything downstream stays here.
  FETCHER = Rails.root.join("lib", "realtor_fetch.py").freeze

  class FetchError < StandardError; end

  # Listings arrive one per line, but they're looked up in batches so a run
  # stays a handful of queries rather than one per listing.
  BATCH_SIZE = 200

  def initialize(search_area)
    @search_area = search_area
  end

  def do_import
    updated = 0
    import_time = Time.current

    each_listing.each_slice(BATCH_SIZE) do |batch|
      ids = batch.map { |attrs| attrs["Id"] }
      listings = Listing.where(external_id: ids).index_by(&:external_id)

      batch.each do |attrs|
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
      print "/"
    end

    puts
    updated
  end

  private

  # Streams one listing at a time so a large search doesn't sit in memory as
  # one big array, and so records land in the DB as they arrive. The fetcher
  # keeps stderr to a couple of lines, so reading it only after stdout is
  # drained can't fill the pipe and deadlock.
  def each_listing
    return to_enum(:each_listing) unless block_given?

    Open3.popen3("python3", FETCHER.to_s, query_params.to_json) do |stdin, stdout, stderr, wait_thread|
      stdin.close

      stdout.each_line do |line|
        next if line.strip.empty?
        yield JSON.parse(line)
      end

      status = wait_thread.value
      unless status.success?
        raise FetchError, "#{FETCHER.basename} exited #{status.exitstatus}: #{stderr.read.strip}"
      end
    end
  end

  def query_params
    {
      LatitudeMax: @search_area.lat_max,
      LongitudeMax: @search_area.lng_max,
      LatitudeMin: @search_area.lat_min,
      LongitudeMin: @search_area.lng_min,
      PropertyTypeGroupID: 1, # Residential
      TransactionTypeId: 2, # For Sale (not rent)
      PropertySearchTypeId: 0,
      ApplicationId: 1,
      CultureId: 1,
      Version: 7.0
    }
  end
end
