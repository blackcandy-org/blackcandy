# frozen_string_literal: true

class StreamController < ApplicationController
  before_action :find_stream

  def new
    if need_transcode? @stream.format
      redirect_to new_transcoded_stream_path(song_id: params[:song_id])
    else
      send_local_file @stream.file_path
    end
  end

  private

  def set_nginx_header
    # Let nginx can get value of media_path dynamically in the nginx config,
    # when use X-Accel-Redirect header to send file.
    response.headers["X-Media-Path"] = Setting.media_path
    response.headers["X-Accel-Redirect"] = File.join("/private_media", @stream.file_path.sub(File.expand_path(Setting.media_path), ""))
  end

  def find_stream
    song = Song.find(params[:song_id])
    @stream = Stream.new(song)
  end

  def nginx_senfile?
    Rails.configuration.action_dispatch.x_sendfile_header == "X-Accel-Redirect"
  end

  def send_local_file(file_path)
    if nginx_senfile?
      set_nginx_header

      send_file file_path
      return
    end

    # Use Rack::File to support HTTP range without nginx. see https://github.com/rails/rails/issues/32193
    Rack::File.new(nil).serving(request, file_path).tap do |(status, headers, body)|
      self.status = status
      self.response_body = body

      headers.each { |name, value| response.headers[name] = value }

      response.headers["Content-Type"] = Mime[@stream.format]
      response.headers["Content-Disposition"] = "attachment"
    end
  end
end
