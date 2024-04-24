namespace :mls do
  desc "Pull available properties from realtor.ca"
  task :import do
    Importer.new.do_import
  end
end
