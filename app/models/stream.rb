# frozen_string_literal: true

class Stream
  TRANSCODING_FORMATS = %w[flac wav].freeze
  TRANSCODE_FORMAT = 'mp3'

  def initialize(song)
    @song = song
  end

  def file_path
    @song.file_path
  end

  def need_transcode?
    @song.format.in? TRANSCODING_FORMATS
  end

  def transcode_file_name
    "#{File.basename(file_path, ".*")}.#{TRANSCODE_FORMAT}"
  end

  # let instance of Stream can respond to each() method.
  # So the download can be streamed, instead of read whole data into memory.
  def each
    # need add error raise when can not found ffmpeg command.
    IO.popen("ffmpeg -i '#{file_path}' -map 0:0 -v 0 -ab 128k -f #{TRANSCODE_FORMAT} -") do |io|
      while line = io.gets do
        yield line
      end
    end
  end
end
