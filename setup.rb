require "rubygems"
require "bundler/setup"

require "active_record"

if ENV["RACK_ENV"] == "production"
  ENV["DATABASE_URL"] =~ %r{^postgres://(.*):(.*)@(.*)/(.*)$}
  ActiveRecord::Base.establish_connection(
    adapter: "postgresql",
    username: $1,
    password: $2,
    host: $3,
    database: $4
  )
else
  ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "db/development.sqlite3")
end

require "./lib/listing"
require "./lib/importer"
