class AddStatusToListings < ActiveRecord::Migration
  def self.up
  	alter_table :listings do |t|
      t.string :status, :default => ''
  	end
  end

  def self.down
  end
end
