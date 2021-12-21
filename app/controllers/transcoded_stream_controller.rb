# frozen_string_literal: true

class TranscodedStreamController < StreamController
  include ActionController::Live

  before_action :find_cache

  # Similar to send_file in rails, but let response_body to be a stream object.
  # The instance of Stream can respond to each() method. So the download can be streamed,
  # instead of read whole data into memory.
  def new
    response.headers["Content-Type"] = Mime[Stream::TRANSCODE_FORMAT]

    File.open(@stream.transcode_cache_file_path, "w") do |file|
      @stream.each do |data|
        response.stream.write data
        file.write data
      end
    end
  rescue ActionController::Live::ClientDisconnected
    logger.info "[#{Time.now.utc}] Stream closed"
  ensure
    response.stream.close
  end

  private

  def find_cache
    if valid_cache?
      redirect_to new_cached_transcoded_stream_path(song_id: params[:song_id])
    end
  end

  def valid_cache?
    return unless File.exist?(@stream.transcode_cache_file_path)

    # Compare duration of cache file and original file to check integrity of cache file.
    # Because the different format of the file, the duration will have a little difference,
    # so the duration difference in two seconds are considered no problem.
    cache_file_tag = WahWah.open(@stream.transcode_cache_file_path)
    (@stream.duration - cache_file_tag.duration).abs <= 2
  end
end
