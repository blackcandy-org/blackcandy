module HtmxRequest
  extend ActiveSupport::Concern

  included do
    helper_method :htmx_request?, :asset_version
    before_action :reload_outdated_assets, if: :htmx_navigation?
    after_action :vary_on_htmx_headers
  end

  private

  def htmx_request?
    request.headers["HX-Request"] == "true" || request.headers["HX-History-Restore-Request"] == "true"
  end

  def htmx_navigation?
    request.get? && (request.headers["HX-Boosted"] == "true" || request.headers["HX-History-Restore-Request"] == "true")
  end

  def vary_on_htmx_headers
    response.headers["Vary"] = [ response.headers["Vary"], "HX-Request", "HX-History-Restore-Request" ].compact.join(", ")
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
