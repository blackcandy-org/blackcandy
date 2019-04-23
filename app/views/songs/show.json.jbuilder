# frozen_string_literal: true

json.(@song, :id, :name, :length)
json.album_name @song.album.title
json.artist_name @song.artist.title
json.album_image_url image_url_for(@song.album, size: 'small')
json.is_favorited @song.favorited?
