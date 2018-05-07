json.(@song, :id, :name, :artist_name, :length)
json.url url_for(@song.media)
json.album_image_url @song.album.image_url
