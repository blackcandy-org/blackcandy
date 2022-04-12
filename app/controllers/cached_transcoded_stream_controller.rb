# frozen_string_literal: true

class CachedTranscodedStreamController < StreamController
  def new
    send_local_file @stream.transcode_cache_file_path
  end

  private

  def set_nginx_header
    response.headers["X-Accel-Redirect"] = File.join("/private_cache_media", @stream.transcode_cache_file_path.sub(Stream::TRANSCODE_CACHE_DIRECTORY.to_s, ""))
  end
end
