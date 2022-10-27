class ThemeChannel < ApplicationCable::Channel
  def subscribed
    stream_from "theme_update"
  end
end
