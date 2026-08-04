module DialogRendering
  extend ActiveSupport::Concern

  included do
    layout -> { "dialog" if dialog? && !native_app? }
    helper_method :dialog?
    before_action :remove_dialog_param_from_referer
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

  def remove_dialog_param_from_referer
    return if request.referer.blank?

    uri = URI.parse(request.referer)
    query = Rack::Utils.parse_nested_query(uri.query).except(DialogHelper::DIALOG_PARAM)
    uri.query = query.to_query.presence

    request.set_header("HTTP_REFERER", uri.to_s)
  rescue
    request.delete_header("HTTP_REFERER")
  end

  def render_dialog_frame
    return unless turbo_frame_request_id == "turbo-dialog" && params[DialogHelper::DIALOG_PARAM].present?

    render partial: "shared/dialog_frame"
  end
end
