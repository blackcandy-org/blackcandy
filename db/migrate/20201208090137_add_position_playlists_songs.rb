class AddPositionPlaylistsSongs < ActiveRecord::Migration[6.0]
  def up
    add_column :playlists_songs, :id, :primary_key
    add_column :playlists_songs, :position, :integer

    execute <<-SQL
      UPDATE playlists_songs
      SET position = mapping.new_position
      FROM (
        SELECT
          id,
          ROW_NUMBER() OVER (
            PARTITION BY playlist_id
            ORDER BY created_at
          ) as new_position
        FROM playlists_songs
      ) AS mapping
      WHERE playlists_songs.id = mapping.id;
    SQL

    remove_column :playlists_songs, :created_at
  end

  def down
    remove_column :playlists_songs, :id
    remove_column :playlists_songs, :position

    add_column :playlists_songs, :created_at, :datetime
  end
end
