class ImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    SearchArea.find_each do |search_area|
      Importer.new(search_area).do_import
    end
  end
end
