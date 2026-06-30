module DialogRendering
  extend ActiveSupport::Concern

  included do
    layout -> { "dialog" if dialog? && !native_app? }
    class_attribute :dialog_actions, default: [], instance_writer: false
    helper_method :dialog?
    before_action :render_dialog_frame
  end

  class_methods do
    def render_in_dialog(*actions)
      self.dialog_actions = actions.empty? ? :all : actions.map(&:to_s)
    end

    def dialog?(action)
      dialog_actions == :all || dialog_actions.include?(action.to_s)
    end
  end

  private

  def dialog?
    self.class.dialog?(action_name)
  end

  def render_dialog_frame
    return unless turbo_frame_request_id == "turbo-dialog" && params[DialogHelper::DIALOG_PARAM].present?

    render partial: "shared/dialog_frame"
  end
end
