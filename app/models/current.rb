# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :setting
  attribute :session
  attribute :ip_address
  attribute :user_agent

  delegate :user, to: :session, allow_nil: true
end
