class SearchArea < ApplicationRecord
  # Sliders in the manage screen adjust width/height in hundredths of a
  # degree, capped here so a fat-fingered drag can't ask realtor.ca for the
  # whole province.
  MAX_SPAN = 0.5

  validates :name, presence: true
  validates :lat_min, :lat_max, :lng_min, :lng_max, presence: true
  validate :bounds_are_ordered
  validate :bounds_are_within_max_span

  def center_lat = (lat_min + lat_max) / 2

  def center_lng = (lng_min + lng_max) / 2

  def height = lat_max - lat_min

  def width = lng_max - lng_min

  # Recomputes the bounding box from a center point and a width/height span,
  # e.g. after the map is dragged or a slider moves. Values are BigDecimal-
  # friendly so callers can pass plain Floats from JSON params.
  def recenter(center_lat:, center_lng:, width: self.width, height: self.height)
    half_height = height.to_f / 2
    half_width = width.to_f / 2

    self.lat_min = center_lat.to_f - half_height
    self.lat_max = center_lat.to_f + half_height
    self.lng_min = center_lng.to_f - half_width
    self.lng_max = center_lng.to_f + half_width
  end

  private

  def bounds_are_ordered
    return if lat_min.blank? || lat_max.blank? || lng_min.blank? || lng_max.blank?

    errors.add(:lat_max, "must be greater than lat_min") if lat_max <= lat_min
    errors.add(:lng_max, "must be greater than lng_min") if lng_max <= lng_min
  end

  def bounds_are_within_max_span
    return if lat_min.blank? || lat_max.blank? || lng_min.blank? || lng_max.blank?

    errors.add(:lat_max, "span can't exceed #{MAX_SPAN} degrees") if height > MAX_SPAN
    errors.add(:lng_max, "span can't exceed #{MAX_SPAN} degrees") if width > MAX_SPAN
  end
end
