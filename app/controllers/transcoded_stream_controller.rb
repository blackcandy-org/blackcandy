# frozen_string_literal: true

class TranscodedStreamController < ApplicationController
  include FileStreaming

  before_action :find_song

  def new
    cached = Transcoder::Cache.complete?(cache_key)

    # Best case: a finished file and a proxy that can accelerate it. No thread
    # is held at all, and Range is the proxy's problem.
    return serve_cache_entry if cached && thruster_sendfile?

    # Otherwise take the socket, which keeps the download off the Puma pool
    # whether the bytes come from the cache or straight off the encoder.
    if Transcoder.available?(request)
      Transcoder.serve(
        request.env["rack.hijack"].call,
        song: @song,
        bitrate: bitrate,
        range: request.headers["Range"]
      )

      # The socket belongs to the transcoder from here on, so the server
      # discards whatever this returns.
      return head :ok
    end

    # Production always has both: x_sendfile_header is set unconditionally and
    # Puma always offers full hijack. Getting here means neither, which no
    # supported deployment can produce.
    head :not_implemented
  end

  private

  def find_song
    @song = Song.find(params[:song_id])
  end

  def bitrate
    @bitrate ||= Setting.transcode_bitrate
  end

  def cache_key
    @cache_key ||= Transcoder::Cache.key(@song, bitrate)
  end

  def serve_cache_entry
    Transcoder::Cache.touch(cache_key)
    serve_file Transcoder::Cache.path(cache_key), type: Mime[Stream::TRANSCODE_FORMAT].to_s
  end
end
