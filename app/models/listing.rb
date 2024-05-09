class Listing < ActiveRecord::Base
  has_many :import_listings, dependent: :destroy

  def self.filtered = where("status != ?", "ignore")

  def self.recent(n = 5) = where("created_at > ?", n.days.ago)

  def self.min_price(price) = price.presence ? where("price > ?", price) : all

  def self.max_price(price) = price.presence ? where("price < ?", price) : all

  def self.price_range(min_price, max_price) = min_price(min_price).max_price(max_price)

  def self.price_spread
    prices = all.pluck(:price)
    sum = prices.sum(0.0)
    size = prices.size
    mean = sum / size
    stddev = Math.sqrt(prices.map { |price| (price - mean)**2 }.sum / size)
    [
      0,
      mean - 1 * stddev,
      mean - 0.5 * stddev,
      mean,
      mean + 0.5 * stddev,
      mean + 1 * stddev,
      mean + 1.5 * stddev
    ].map { |price| price.round(-4) } + [Float::INFINITY]
  end

  def last_imported = import_listings.last&.json || {}

  def last_update = imported_at.strftime("%b %d")

  def marker_icon(price_spread)
    index = price_spread.index { |spread| price < spread }
    if starred?
      "star#{index}"
    elsif imported_at > 12.hours.ago # TODO: Most recent import
      "house#{index}gs"
    elsif imported_at > 3.days.ago
      "house#{index}ss"
    else
      "house#{index}"
    end
  end

  def sync_last_import!
    last = last_imported
    self.lat = last.dig("Property", "Address", "Latitude")
    self.lng = last.dig("Property", "Address", "Longitude")
    self.address = last.dig("Property", "Address", "AddressText").to_s.split("|").first
    self.price = last.dig("Property", "Price").to_s.gsub(/[^0-9]/, "").to_i
    self.bedrooms = last.dig("Building", "Bedrooms")
    self.bathrooms = last.dig("Building", "BathroomTotal")
    self.external_url = "https://www.realtor.ca#{last_imported.dig("RelativeURLEn")}"
    self.tooltip_photo = last.dig("Property", "Photo", 0, "MedResPath")

    if changed?
      self.imported_at = Time.now
      save
    end
  end
end
