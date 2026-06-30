# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  include RequestForgeryProtection
  include Authentication
  include Authorization
  include ClientDetection
  include RequestDetection
  include ExceptionRescue
  include Flashy
  include Pagination
  include DialogRendering

  allow_browser versions: :modern, block: -> { render template: "errors/unsupported_browser", layout: "plain", status: :not_acceptable }
end
