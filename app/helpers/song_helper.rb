# frozen_string_literal: true

module SongHelper
  def song_json_builder(song)
    stream_url = new_stream_url(song_id: song.id)
    transcoded_stream_url = new_transcoded_stream_url(song_id: song.id)

    Jbuilder.new do |json|
      json.call(song, :id, :name, :duration, :album_id, :artist_id)
      json.url need_transcode?(song) ? transcoded_stream_url : stream_url
      json.album_name song.album.name
      json.artist_name song.artist.name
      json.is_favorited song.is_favorited.nil? ? Current.user.favorited?(song) : song.is_favorited
      json.format need_transcode?(song) ? Stream::TRANSCODE_FORMAT : song.format
      json.lyrics_url song_lyrics_url(song)
      json.album_image_urls do
        json.small URI.join(root_url, cover_image_url_for(song.album, size: :small))
        json.medium URI.join(root_url, cover_image_url_for(song.album, size: :medium))
        json.large URI.join(root_url, cover_image_url_for(song.album, size: :large))
      end
    end
  end
end
