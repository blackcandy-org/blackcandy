module DialogHelper
  DIALOG_PARAM = "dialog"

  def self.verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(
      Rails.application.key_generator.generate_key(DIALOG_PARAM),
      url_safe: true
    )
  end

  def dialog_link_to(name, path, **options)
    return link_to name, path, **options if native_app?

    options[:data] = (options[:data] || {}).merge("turbo-frame" => "turbo-dialog", "turbo-action" => "advance")
    link_to name, "?#{request.query_parameters.merge(DIALOG_PARAM => DialogHelper.verifier.generate(path)).to_query}", **options
  end

  def dialog_frame_src
    DialogHelper.verifier.verified(params[DIALOG_PARAM])
  end
end
