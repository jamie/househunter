class CreateListings < ActiveRecord::Migration[7.1]
  def change
    create_table :listings do |t|
      t.integer :external_id
      t.string :status, default: ""
      t.string :lat
      t.string :lng
      t.string :address
      t.integer :price
      t.text :json, default: ""
      t.datetime :imported_at

      t.timestamps
    end
  end
end
