class Listing < ActiveRecord::Base
  def self.import(attrs)
    listing = where(:mls => attrs['MLS']).first
    listing ||= create(:mls => attrs['MLS'])
    listing.record(attrs)
    listing.import!
  end

  def record(attrs)
    return if last_import == attrs
    self.json << "\n" << attrs.to_json
    self.last_import = Time.now
    save
  end

  def last_import
    JSON.parse(json.split("\n").last) rescue nil
  end

  def import!
    a = last_import
    self.lat =     a['Latitude']
    self.lng =     a['Longitude']
    self.address = a['Address']
    self.price =   a['Price']
    save
  end
end
