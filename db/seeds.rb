# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# The area Importer#query_params used to hard-code.
SearchArea.find_or_create_by!(name: "Vancouver") do |area|
  area.lat_min = 49.03
  area.lat_max = 49.33
  area.lng_min = -124.08
  area.lng_max = -123.88
end
