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

  # Auto-migrate on boot
  migrations = ActiveRecord::Migration.new.migration_context.migrations
  connection = ActiveRecord::Tasks::DatabaseTasks.migration_connection
  schema_migration = ActiveRecord::SchemaMigration.new(connection)
  internal_metadata = ActiveRecord::InternalMetadata.new(connection)

  ActiveRecord::Migrator.new(:up, migrations, schema_migration, internal_metadata).migrate
end

require "./lib/listing"
require "./lib/importer"
