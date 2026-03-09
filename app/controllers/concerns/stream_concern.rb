# frozen_string_literal: true

module StreamConcern
  extend ActiveSupport::Concern

  included do
    before_action :find_stream
  end

  def new
    send_local_file @stream.file_path
  end

  private

  def find_stream
    @stream = Stream.new(Song.find(params[:song_id]))
  end

  def thruster_sendfile?
    Rails.configuration.action_dispatch.x_sendfile_header == "X-Sendfile"
  end

  def send_local_file(file_path)
    if thruster_sendfile?
      send_file file_path
      return
    end

    # Use Rack::File to support HTTP range on local without thruster. see https://github.com/rails/rails/issues/32193
    Rack::Files.new(nil).serving(request, file_path).tap do |(status, headers, body)|
      self.status = status
      self.response_body = body

      headers.each { |name, value| response.headers[name] = value }

      response.headers["Content-Type"] = Mime[@stream.format]
      response.headers["Content-Disposition"] = "attachment"
    end
  end
end
