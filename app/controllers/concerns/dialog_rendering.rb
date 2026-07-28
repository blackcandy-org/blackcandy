module DialogRendering
  extend ActiveSupport::Concern

  included do
    layout -> { "dialog" if dialog? && !native_app? }
    helper_method :dialog?
    before_action :render_dialog_frame
  end

  class_methods do
    def render_in_dialog(**options)
      before_action(**options) { @dialog = true }
    end
  end

  private

  def dialog?
    !!@dialog
  end

  def render_dialog_frame
    return unless turbo_frame_request_id == "turbo-dialog" && params[DialogHelper::DIALOG_PARAM].present?

    render partial: "shared/dialog_frame"
  end
end
