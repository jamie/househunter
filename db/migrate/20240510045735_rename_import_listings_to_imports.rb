class RenameImportListingsToImports < ActiveRecord::Migration[7.1]
  def change
    drop_table :imports
    rename_table :import_listings, :imports
  end
end
