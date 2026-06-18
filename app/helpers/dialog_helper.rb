module DialogHelper
  DIALOG_PARAM = "dialog"

  def dialog_link_to(name, path, **options)
    options[:data] = (options[:data] || {}).merge("turbo-frame" => "turbo-dialog", "turbo-action" => "advance")
    link_to name, "?#{request.query_parameters.merge(DIALOG_PARAM => path).to_query}", **options
  end

  def dialog_frame_src
    path = params[DIALOG_PARAM]
    return if path.blank?

    path if dialog_path?(path)
  end

  private

  def dialog_path?(path)
    return false unless path.match?(%r{\A/[^/]})

    controller = "#{Rails.application.routes.recognize_path(path)[:controller]}_controller".classify.constantize
    controller <= Dialog::ApplicationController
  rescue
    false
  end
end
