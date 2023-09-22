# frozen_string_literal: true

class ApiError
  TYPES = {
    record_not_unique: "RecordNotUnique",
    invalid_credential: "InvalidCredential"
  }

  attr_reader :type, :message

  def initialize(type_key, message)
    @type = TYPES[type_key]
    @message = message
  end

  def to_json(*_args)
    {type: @type, message: @message}.to_json
  end
end
