class EnableTrigramExtension < ActiveRecord::Migration[6.0]
  def change
    enable_extension "pg_trgm" if adapter_name.downcase == "postgresql" && !extension_enabled?("pg_trgm")
  end
end
