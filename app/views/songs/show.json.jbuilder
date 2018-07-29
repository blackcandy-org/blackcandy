# frozen_string_literal: true

json.(@song, :id, :name, :length)
json.url new_stream_path(song_id: @song.id)
# json.album_image_url url_for(@song.album.image)
