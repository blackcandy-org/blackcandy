# frozen_string_literal: true

class CurrentPlaylist::SongsController < Playlists::SongsController
  layout "playlist"

  def show
    @songs = @playlist.songs.includes(:artist)
  end

  def create
    if params[:location] == "last"
      @playlist.songs.push(@song)
    else
      @current_song_position = @playlist.playlists_songs.find_by(song_id: params[:current_song_id])&.position.to_i
      @playlist.playlists_songs.create(song_id: @song.id, position: @current_song_position + 1)
    end

    flash.now[:success] = t("success.add_to_playlist")

    redirect_to action: "show" if @playlist.songs.count == 1
  rescue ActiveRecord::RecordNotUnique
    flash.now[:error] = t("error.already_in_playlist")
    render turbo_stream: render_flash
  end

  private

  def find_playlist
    @playlist = Current.user.current_playlist
  end
end
