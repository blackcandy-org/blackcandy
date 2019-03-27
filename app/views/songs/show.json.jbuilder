# frozen_string_literal: true

json.(@song, :id, :name, :length, :album_name, :artist_name)
json.url new_stream_path(song_id: @song.id)
json.album_image_url image_url_for(@song.album, size: 'small')
json.is_favorited @song.favorited?
