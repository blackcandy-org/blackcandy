# frozen_string_literal: true

module TranscodedStreamConcern
  extend ActiveSupport::Concern

  included do
    before_action :find_stream
    before_action :find_cache
  end

  # Similar to send_file in rails, but let response_body to be a stream object.
  # The instance of Stream can respond to each() method. So the download can be streamed,
  # instead of read whole data into memory.
  def new
    # Because the module ActionController::Live contains methods that can block send file.
    # So can't simply include ActionController::Live in class, otherwise include this module only on this method.
    self.class.send(:include, ActionController::Live)

    response.headers["Content-Type"] = Mime[Stream::TRANSCODE_FORMAT]

    send_stream(filename: "#{@stream.name}.mp3") do |stream_response|
      File.open(@stream.transcode_cache_file_path, "w") do |file|
        @stream.each do |data|
          stream_response.write data
          file.write data
        end
      end
    end
  end

  private

  def find_stream
    @stream = Stream.new(Song.find(params[:song_id]))
  end

  def find_cache
    return unless valid_cache?
    send_file @stream.transcode_cache_file_path
  end

  def valid_cache?
    # Compare duration of cache file and original file to check integrity of cache file.
    # Because the different format of the file, the duration will have a little difference,
    # so the duration difference in two seconds are considered no problem.
    cache_file_tag = WahWah.open(@stream.transcode_cache_file_path)
    (@stream.duration - cache_file_tag.duration).abs <= 2
  rescue
    false
  end
end
