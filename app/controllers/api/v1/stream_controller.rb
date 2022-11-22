# frozen_string_literal: true

module Api
  module V1
    class StreamController < ApiController
      before_action :find_stream

      def new
        if nginx_sendfile?
          # Let nginx can get value of media_path dynamically in the nginx config,
          # when use X-Accel-Redirect header to send file.
          response.headers["X-Media-Path"] = Setting.media_path
          response.headers["X-Accel-Redirect"] = File.join("/private_media", @stream.file_path.sub(File.expand_path(Setting.media_path), ""))
        end

        send_file @stream.file_path
      end

      private

      def find_stream
        song = Song.find(params[:song_id])
        @stream = Stream.new(song)
      end

      def nginx_sendfile?
        ENV.fetch("NGINX_SENDFILE", "false") == "true"
      end
    end
  end
end
