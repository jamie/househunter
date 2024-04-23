class Hash
  def diff(h2)
    dup.delete_if { |k, v| h2[k] == v }.merge(h2.dup.delete_if { |k, v| has_key?(k) })
  end
end

class Listing < ActiveRecord::Base
  IGNORED_ATTRS = %w[Individual Business TimeOnRealtor Tags]
  UNIMPORTANT_ATTRS = IGNORED_ATTRS + %w[HasNewImageUpdate]

  def self.filtered
    where("status != ?", "ignore")
  end

  def self.recent
    where("updated_at > ?", 5.days.ago)
  end

  def self.import(attrs)
    listing = find_or_create_by(external_id: attrs["Id"])
    listing.record(attrs)
    listing.import!
  end

  def record(attrs)
    return if last_imported == attrs
    return if ((last_imported.diff attrs).keys - IGNORED_ATTRS).empty?
    if json.blank?
      print "*"
      self.json = attrs.to_json
      self.imported_at = Time.now
    else
      print "."
      p(last_imported.diff(attrs))
      p(attrs.diff(last_imported))
      self.json = json + "\n" + attrs.to_json
      if !((last_imported.diff attrs).keys - UNIMPORTANT_ATTRS).empty?
        self.imported_at = Time.now
      end
    end
    save
  end

  def last_imported
    JSON.parse((json || "").split("\n").last || "{}")
  end

  def import!
    a = last_imported
    self.lat = a.dig("Property", "Address", "Latitude")
    self.lng = a.dig("Property", "Address", "Longitude")
    self.address = a.dig("Property", "Address", "AddressText").split("|").first
    self.price = a.dig("Property", "Price").gsub(/[^0-9]/, "").to_i
    save
  end

  def map_icon_uri
    return "/starpin.png" if status == "remember"

    color = if price < 180_000 then "pink"
    elsif price < 210_000 then "purple"
    elsif price < 240_000 then "blue"
    elsif price < 270_000 then "green"
    elsif price < 300_000 then "yellow"
    elsif price < 330_000 then "orange"
    else
      "red"
    end
    style = ((imported_at > 20.hours.ago) ? "-dot" : "")
    "http://maps.google.com/mapfiles/ms/icons/#{color}#{style}.png"
  end

  def url
    id = last_imported["PropertyID"]
    key = last_imported["PidKey"]
    "http://www.realtor.ca/propertyDetails.aspx?propertyId=#{id}&PidKey=#{key}"
  end

  def tooltip_photo
    last_imported.dig("Property", "Photo", 0, "MedResPath")
  end
end
