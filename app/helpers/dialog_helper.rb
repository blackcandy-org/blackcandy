module DialogHelper
  DIALOG_PARAM = "dialog"

  def self.verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(
      Rails.application.key_generator.generate_key(DIALOG_PARAM),
      url_safe: true
    )
  end

  def dialog_link_to(name, path, **options)
    url = "?#{request.query_parameters.merge(DIALOG_PARAM => DialogHelper.verifier.generate(path)).to_query}"
    link_to name, url, **options.deep_merge(turbo_frame_target("turbo-dialog"))
  end

  def dialog_frame_src
    DialogHelper.verifier.verified(params[DIALOG_PARAM])
  end
end
