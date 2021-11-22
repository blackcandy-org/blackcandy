class UseHstoreForSettings < ActiveRecord::Migration[6.0]
  def up
    enable_extension "hstore" unless extension_enabled?("hstore")
    add_column :settings, :values, :hstore
    add_column :settings, :singleton_guard, :integer
    add_column :users, :settings, :hstore
    add_index :settings, :singleton_guard, unique: true
    remove_columns :settings, :created_at, :updated_at

    execute <<-SQL
      /* Migrate user theme settings */
      UPDATE users u
      SET
        settings = hstore('theme', regexp_replace(s.value, '^--- |\n$', '', 'g'))
      FROM
        settings s
      WHERE
        s.thing_id = u.id AND s.thing_type = 'User' AND s.var = 'theme';

      /* Create new global setting */
      INSERT INTO settings (var, singleton_guard)
      VALUES ('temp', 0);

      /* Migrate setting of discogs_token to new global setting */
      UPDATE settings
      SET values = hstore('discogs_token', (
        SELECT
          regexp_replace(value, '^--- |\n$', '', 'g')
        FROM
          settings
        WHERE
          var = 'discogs_token'
        LIMIT 1
      ))
      WHERE
        singleton_guard = 0;

      /* Migrate setting of media_path to new global setting */
      UPDATE settings
      SET values = values || hstore('media_path', (
        SELECT
          regexp_replace(value, '^--- |\n$', '', 'g')
        FROM
          settings
        WHERE
          var = 'media_path'
        LIMIT 1
      ))
      WHERE
        singleton_guard = 0;
    SQL

    remove_columns :settings, :var, :value, :thing_id, :thing_type

    execute <<-SQL
      /* Clean up global settings */
      DELETE FROM settings WHERE singleton_guard IS NULL;
    SQL
  end

  def down
    execute <<-SQL
      TRUNCATE TABLE settings;
    SQL

    add_column :settings, :var, :string, null: false
    add_column :settings, :value, :text
    add_column :settings, :thing_id, :integer
    add_column :settings, :thing_type, :string, limit: 30
    add_timestamps :settings
    add_index :settings, [:thing_type, :thing_id, :var], unique: true

    remove_column :settings, :values
    remove_column :settings, :singleton_guard
    remove_column :users, :settings
    disable_extension "hstore" if extension_enabled?("hstore")
  end
end
