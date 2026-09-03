# frozen_string_literal: true

class StreamController < ApplicationController
  include FileStreaming

  before_action :find_stream

  def new
    serve_file @stream.file_path, type: Mime[@stream.format].to_s
  end

  private

  def find_stream
    @stream = Stream.new(Song.find(params[:song_id]))
  end
end
