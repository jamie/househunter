class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.integer :mls
      t.string :lat
      t.string :lng
      t.string :address
      t.string :price
      t.text :json, :default => ''
      t.datetime :last_import

      t.timestamps
    end
  end
end
