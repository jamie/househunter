namespace :mls do
  desc "Pull available properties from realtor.ca"
  task import: :environment do
    SearchArea.find_each do |search_area|
      Importer.new(search_area).do_import
    end
  end
end
