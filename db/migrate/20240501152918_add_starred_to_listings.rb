class AddStarredToListings < ActiveRecord::Migration[7.1]
  def change
    add_column :listings, :starred, :boolean, default: false
  end
end
