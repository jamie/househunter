#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require './setup'

require 'sinatra/activerecord/rake'

namespace :mls do
  desc 'Pull available properties from realtor.ca'
  task :import do
    Importer.new.do_import
  end
end
