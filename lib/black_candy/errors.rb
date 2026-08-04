# frozen_string_literal: true

module BlackCandy
  class BaseError < StandardError
    def type
      self.class.name.split("::").last
    end
  end

  class Forbidden < BaseError
    def message
      I18n.t("error.forbidden")
    end
  end

  class InvalidCredential < BaseError
    def message
      I18n.t("error.login")
    end
  end

  class Unauthorized < BaseError
    def message
      I18n.t("error.unauthorized")
    end
  end
end
