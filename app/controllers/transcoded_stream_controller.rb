# frozen_string_literal: true

class TranscodedStreamController < StreamController
  include ActionController::Live

  # Similar to send_file in rails, but let response_body to be a stream object.
  # The instance of Stream can respond to each() method. So the download can be streamed,
  # instead of read whole data into memory.
  def new
    response.headers['Content-Type'] = Mime[Stream::TRANSCODE_FORMAT]

    @stream.each do |data|
      response.stream.write data
    end
  rescue ActionController::Live::ClientDisconnected
    logger.info "[#{Time.now.utc}] Stream closed"
  ensure
    response.stream.close
  end
end
