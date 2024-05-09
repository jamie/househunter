class CreateImportListings < ActiveRecord::Migration[7.1]
  def change
    create_table :import_listings do |t|
      t.references :import
      t.references :listing
      t.text :json, limit: 2**16 - 1

      t.timestamps
    end
  end
end
