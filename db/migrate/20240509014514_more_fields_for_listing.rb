class MoreFieldsForListing < ActiveRecord::Migration[7.1]
  def change
    add_column :listings, :bedrooms, :integer
    add_column :listings, :bathrooms, :integer
    add_column :listings, :external_url, :string
    add_column :listings, :tooltip_photo, :string
  end
end
