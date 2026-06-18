module DialogRendering
  extend ActiveSupport::Concern

  included do
    before_action :render_dialog_frame
  end

  private

  def render_dialog_frame
    return unless turbo_frame_request_id == "turbo-dialog" && params[DialogHelper::DIALOG_PARAM].present?

    render partial: "shared/dialog_frame"
  end
end
