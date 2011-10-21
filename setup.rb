require 'rubygems'
require 'bundler/setup'

require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'db/development.sqlite3')

require './lib/listing'
require './lib/importer'
