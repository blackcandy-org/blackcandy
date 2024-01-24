# frozen_string_literal: true

require "open-uri"

class Integrations::Service
  include HTTParty

  def request(path, options = {}, method = :get)
    response = self.class.send(method, path, options)
    raise TooManyRequests if response.code.to_i == 429

    parse_json(response)
  end

  def download_image(url)
    image_file = OpenURI.open_uri(url)
    content_type = image_file.content_type
    image_format = Mime::Type.lookup(content_type).symbol
    return unless image_format.present?

    {
      io: image_file,
      filename: "cover.#{image_format}",
      content_type: content_type
    }
  rescue OpenURI::HTTPError => e
    raise TooManyRequests if e.io.status[0].to_i == 429
  end

  private

  def parse_json(response)
    JSON.parse response.body, symbolize_names: true if response.success?
  end

  class TooManyRequests < StandardError; end
end
