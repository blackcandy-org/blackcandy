json.(@song, :id, :album_name, :artist_name)
json.url @song.media.service_url
