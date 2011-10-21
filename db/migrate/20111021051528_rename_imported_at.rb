class RenameImportedAt < ActiveRecord::Migration
  def self.up
  	rename_column :listings, :last_import, :imported_at
  end

  def self.down
  	rename_column :listings, :imported_at, :last_import
  end
end
