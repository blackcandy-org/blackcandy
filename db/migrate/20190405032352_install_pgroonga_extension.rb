class InstallPgroongaExtension < ActiveRecord::Migration[5.2]
  def up
    execute "CREATE EXTENSION IF NOT EXISTS pgroonga;"
  end

  def down
    execute "DROP EXTENSION IF EXISTS pgroonga;"
  end
end
