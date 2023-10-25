# frozen_string_literal: true

module StreamConcern
  extend ActiveSupport::Concern

  included do
    before_action :find_stream
  end

  def new
    send_local_file @stream.file_path, @stream.format, nginx_headers: {
      # Let nginx can get value of media_path dynamically in the nginx config
      # when use X-Accel-Redirect header to send file.
      "X-Media-Path" => Setting.media_path,
      "X-Accel-Redirect" => File.join("/private_media", @stream.file_path.sub(File.expand_path(Setting.media_path), ""))
    }
  end

  private

  def find_stream
    @stream = Stream.new(Song.find(params[:song_id]))
  end
end
