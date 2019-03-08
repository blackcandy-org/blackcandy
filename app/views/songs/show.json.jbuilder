# frozen_string_literal: true

json.(@song, :id, :name, :length, :album_name, :artist_name)
json.url new_stream_path(song_id: @song.id)
json.album_image_url album_image_url(@song.album)
json.is_favorited @song.favorited?
