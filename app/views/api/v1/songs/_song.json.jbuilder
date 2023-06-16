json.call(song, :id, :name, :duration)
json.url need_transcode?(song) ? new_api_v1_transcoded_stream_url(song_id: song.id) : new_api_v1_stream_url(song_id: song.id)
json.album_name song.album.title
json.artist_name song.artist.title
json.is_favorited song.is_favorited || Current.user.favorited?(song)
json.format need_transcode?(song) ? Stream::TRANSCODE_FORMAT : song.format
json.album_image_url do
  json.small URI.join(root_url, image_url_for(song.album, size: "small"))
  json.medium URI.join(root_url, image_url_for(song.album, size: "medium"))
  json.large URI.join(root_url, image_url_for(song.album, size: "large"))
end
