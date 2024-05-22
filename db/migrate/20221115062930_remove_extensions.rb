class RemoveExtensions < ActiveRecord::Migration[7.0]
  def change
    disable_extension "pg_trgm"
    disable_extension "hstore"
    disable_extension "plpgsql"
  end
end
