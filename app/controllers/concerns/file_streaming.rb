# frozen_string_literal: true

module FileStreaming
  extend ActiveSupport::Concern

  private

  def serve_file(path, type:)
    # Rack::Files honours Range but never says so, and the hijacked path does
    # advertise it. Without this the same track would claim to be seekable
    # while it is being encoded and stop claiming it once it is cached.
    response.headers["Accept-Ranges"] = "bytes"

    if thruster_sendfile?
      send_file path, type: type
      return
    end

    # Use Rack::File to support HTTP range on local without thruster. see https://github.com/rails/rails/issues/32193
    Rack::Files.new(nil).serving(request, path).tap do |(status, headers, body)|
      self.status = status
      self.response_body = body

      headers.each do |name, value|
        # Rack::Files marks its refusals to be retried further down the stack.
        # Passing that on makes Rails resume routing, find nothing, and turn a
        # 416 into a 404.
        next if name.casecmp("x-cascade").zero?

        response.headers[name] = value
      end

      # A refusal keeps the plain text body and type Rack::Files gave it.
      next unless response.successful?

      response.headers["Content-Type"] = type
      response.headers["Content-Disposition"] = "attachment"
    end
  end

  def thruster_sendfile?
    Rails.configuration.action_dispatch.x_sendfile_header == "X-Sendfile"
  end
end
