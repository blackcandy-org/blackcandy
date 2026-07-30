# frozen_string_literal: true

class Songs::LyricsController < ApplicationController
  before_action :find_song
  before_action :redirect_to_attached_lyrics

  def show
    return head :no_content if @song.external_lyrics_file_path.blank?

    send_file @song.external_lyrics_file_path, type: "text/plain"
  end

  private

  def find_song
    @song = Song.find(params[:song_id])
  end

  def redirect_to_attached_lyrics
    return unless @song.lyrics.attached?

    redirect_to url_for(@song.lyrics)
  end
end
