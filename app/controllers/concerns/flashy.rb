module Flashy
  extend ActiveSupport::Concern

  included do
    helper_method :flash_partial
  end

  private

  def flash_partial(type: :notice, message: "")
    flash.now[type] = message unless message.blank?
    view_context.content_tag "hx-partial", view_context.render("shared/flash"), "hx-target": "#hx-flash", "hx-swap": "outerHTML"
  end
end
