# frozen_string_literal: true

class CurrentPlaylist::SongsController < Playlists::SongsController
  layout "playlist"

  skip_before_action :redirect_to_built_in_playlist

  def index
    @songs = @playlist.songs_with_favorite
    @should_play = params[:should_play] == "true"
    @should_play_song_id = params[:song_id].to_i if @should_play
  end

  def create
    @song = Song.find(params[:song_id])

    if params[:location] == "last"
      @playlist.songs.push(@song)
    else
      @current_song_position = @playlist.playlists_songs.find_by(song_id: params[:current_song_id])&.position.to_i
      @playlist.playlists_songs.create(song_id: @song.id, position: @current_song_position + 1)
    end

    flash.now[:success] = t("notice.added_to_playlist")

    redirect_to action: "index", should_play: params[:should_play] if @playlist.songs.count == 1
  rescue ActiveRecord::RecordNotUnique
    flash.now[:error] = t("error.already_in_playlist")
    render turbo_stream: render_flash
  end

  private

  def find_playlist
    @playlist = Current.user.current_playlist
  end
end
