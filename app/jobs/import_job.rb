class ImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Importer.new.do_import
  end
end
