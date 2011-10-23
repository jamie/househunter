require 'rubygems'
require 'bundler/setup'

require 'active_record'

if ENV['RACK_ENV'] == 'production'
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'db/development.sqlite3')
end

require './lib/listing'
require './lib/importer'
