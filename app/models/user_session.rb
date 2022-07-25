# frozen_string_literal: true

class UserSession < Authlogic::Session::Base
  secure Rails.application.config.force_ssl
end
