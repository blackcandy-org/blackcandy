module HtmxRequest
  extend ActiveSupport::Concern

  HX_PARTIAL = %r{<hx-partial\b.*?</hx-partial>}m

  included do
    helper_method :htmx_request?, :asset_version
    before_action :reload_outdated_assets, if: :htmx_navigation?
    after_action :vary_on_htmx_headers
    after_action :skip_history_for_partials, if: :boosted_request?
  end

  private

  def htmx_request?
    request.headers["HX-Request"] == "true" || request.headers["HX-History-Restore-Request"] == "true"
  end

  def partial_request?
    request.headers["HX-Request-Type"] == "partial"
  end

  def boosted_request?
    request.headers["HX-Boosted"] == "true"
  end

  def htmx_navigation?
    request.get? && (boosted_request? || request.headers["HX-History-Restore-Request"] == "true")
  end

  def vary_on_htmx_headers
    response.headers["Vary"] = [ response.headers["Vary"], "HX-Request", "HX-Request-Type", "HX-History-Restore-Request" ].compact.join(", ")
  end

  def skip_history_for_partials
    body = response.body
    return unless response.media_type == "text/html" && body.include?("<hx-partial")

    response.set_header("HX-Push-Url", "false") if body.gsub(HX_PARTIAL, "").blank?
  end

  def asset_version
    @asset_version ||= %w[application.js application.css].map { |path| Propshaft::Asset.extract_path_and_digest(helpers.asset_path(path)).last }.join("-")
  end

  def reload_outdated_assets
    return if request.headers["X-Asset-Version"] == asset_version

    response.set_header("HX-Redirect", request.url)
    head :ok
  end
end
