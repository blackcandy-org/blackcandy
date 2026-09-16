# frozen_string_literal: true

module SessionHelper
  def session_details(session)
    [ session.client_name, session.client_platform, session.ip_address ].reject(&:blank?).join(" · ")
  end
end
