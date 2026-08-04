module ExceptionRescue
  extend ActiveSupport::Concern

  included do
    rescue_from BlackCandy::Forbidden do |error|
      respond_to do |format|
        format.json { render_json_error(error.type, error.message, :forbidden) }
        format.html { render template: "errors/forbidden", layout: "plain", status: :forbidden }
      end
    end

    rescue_from BlackCandy::InvalidCredential do |error|
      respond_to do |format|
        format.json { render_json_error(error.type, error.message, :unauthorized) }
        format.html { redirect_to new_session_path, alert: t("error.login") }
      end
    end

    rescue_from BlackCandy::Unauthorized do |error|
      respond_to do |format|
        format.json { render_json_error(error.type, error.message, :unauthorized) }
        format.html { redirect_to new_session_path }
      end
    end

    rescue_from ActiveRecord::RecordNotFound do |error|
      respond_to do |format|
        format.json { render_json_error("RecordNotFound", error.message, :not_found) }
        format.html { render template: "errors/not_found", layout: "plain", status: :not_found }
      end
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      errors_message = error.record.errors.full_messages.join(". ")

      respond_to do |format|
        format.json { render_json_error("RecordInvalid", errors_message, :unprocessable_entity) }
        format.html { redirect_back_or_to root_path, alert: errors_message }
      end
    end
  end

  private

  def render_json_error(type, message, status)
    render json: { type: type, message: message }, status: status
  end
end
