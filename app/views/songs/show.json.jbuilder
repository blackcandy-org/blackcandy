# frozen_string_literal: true

json.call(@song, :id, :name, :length)
json.url new_stream_path(song_id: @song.id)
json.album_name @song.album.title
json.artist_name @song.artist.title
json.is_favorited Current.user.favorited? @song
json.format @song_format
json.album_image_url do
  json.small image_url_for(@song.album, size: "small")
  json.medium image_url_for(@song.album, size: "medium")
  json.large image_url_for(@song.album, size: "large")
end
