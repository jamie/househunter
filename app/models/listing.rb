class Listing < ActiveRecord::Base
  UNLIMITED_AGE = 28

  has_many :imports, dependent: :destroy

  def self.filtered = where.not(status: "ignore")

  def self.starred = where(starred: true)

  def self.fresh = where(updated_at: 3.days.ago..)

  def self.recent(n = 5)
    if n.to_i == UNLIMITED_AGE
      all
    else
      where(created_at: (n.to_i + 1).days.ago..)
    end
  end

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
  rescue
    [0, 200_000, 400_000, 600_000, 800_000, 1_000_000, 1_200_000, Float::INFINITY]
  end

  def last_imported = imports.last&.json || {}

  def sqft = last_imported.dig("Building", "SizeInterior")

  def history
    Listing.where(address: address).where.not(id: id).order("created_at desc").select(:updated_at, :price)
  end

  def marker_icon(price_spread, last_import)
    index = price_spread.index { |spread| price < spread }
    if starred?
      "star#{index}"
    elsif created_at > 16.hours.ago
      "house#{index}new"
    elsif imported_at > 3.days.ago
      "house#{index}recent"
    else
      "house#{index}"
    end
  end
end
