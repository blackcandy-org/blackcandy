module Flashy
  extend ActiveSupport::Concern

  included do
    helper_method :stream_flash
  end

  private

  def stream_flash(type: :notice, message: "")
    flash.now[type] = message unless message.blank?
    turbo_stream.replace "turbo-flash", partial: "shared/flash"
  end
end
