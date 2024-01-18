# frozen_string_literal: true

class Integrations::Service
  include HTTParty

  class << self
    def parsed_json(response)
      JSON.parse response, symbolize_names: true if response.success?
    end
  end
end
