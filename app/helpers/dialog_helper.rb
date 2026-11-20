module DialogHelper
  DIALOG_PARAM = "dialog"

  def self.verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(
      Rails.application.key_generator.generate_key(DIALOG_PARAM),
      url_safe: true
    )
  end

  def dialog_link_to(name, path, **options)
    page_url = "?#{request.query_parameters.merge(DIALOG_PARAM => DialogHelper.verifier.generate(path)).to_query}"
    link_to name, page_url, **options, "hx-get": path, "hx-target": "#hx-dialog", "hx-push-url": page_url
  end

  def dialog_src
    DialogHelper.verifier.verified(params[DIALOG_PARAM])
  end
end
