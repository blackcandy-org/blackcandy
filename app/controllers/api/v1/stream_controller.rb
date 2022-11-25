# frozen_string_literal: true

module Api
  module V1
    class StreamController < ApiController
      before_action :find_stream

      def new
        send_local_file @stream.file_path
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

      def send_local_file(file_path)
        if BlackCandy::Config.nginx_sendfile?
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
  end
end
