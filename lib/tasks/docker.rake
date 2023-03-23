# frozen_string_literal: true

namespace :docker do
  # Prepare database. Beacuse when the database adapter is sqlite, the task 'db:prepare' won't run 'db:seed'.
  # So add 'db:seed' task explicitly to avoit it. See https://github.com/rails/rails/issues/36383.
  # Note: this issue is fixed in Rails master branch. This code is also base the code on Rails master branch.
  # See here: https://github.com/rails/rails/blob/2cef3ac45bd85e1642b1270ab4fa31629044c962/activerecord/lib/active_record/tasks/database_tasks.rb#L179.
  # So this is just temprary fix. This task can be replace with 'db:prepare' in the future after Rails 7.1 is released.
  task db_prepare: :environment do
    begin
      database_initialized = ActiveRecord::Base.connection.schema_migration.table_exists?
    rescue ActiveRecord::NoDatabaseError
      database_initialized = false
    end

    Rake::Task["db:prepare"].invoke

    unless database_initialized
      Rake::Task["db:seed"].invoke
    end
  end
end
