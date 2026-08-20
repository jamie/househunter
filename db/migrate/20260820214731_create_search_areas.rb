class CreateSearchAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :search_areas do |t|
      t.text :name
      t.decimal :lat_min, precision: 9, scale: 6
      t.decimal :lat_max, precision: 9, scale: 6
      t.decimal :lng_min, precision: 9, scale: 6
      t.decimal :lng_max, precision: 9, scale: 6
      t.decimal :radius, precision: 9, scale: 6

      t.timestamps
    end
  end
end
