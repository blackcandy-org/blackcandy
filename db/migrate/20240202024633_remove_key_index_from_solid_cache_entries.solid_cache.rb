# This migration comes from solid_cache (originally 20240110111702)
class RemoveKeyIndexFromSolidCacheEntries < ActiveRecord::Migration[7.1]
  def change
    change_table :solid_cache_entries do |t|
      t.remove_index :key, unique: true
    end
  end
end
