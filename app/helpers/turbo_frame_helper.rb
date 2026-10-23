module TurboFrameHelper
  # For a link or form outside a Turbo Frame that loads into one. With Turbo Drive off,
  # Turbo only takes these with data-turbo="true", and hx-boost="false" keeps htmx off them.
  def turbo_frame_target(frame, **data)
    { "hx-boost": "false", data: { turbo: true, turbo_frame: frame, **data } }
  end
end
