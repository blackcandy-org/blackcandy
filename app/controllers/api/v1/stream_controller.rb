# frozen_string_literal: true

module Api
  module V1
    class StreamController < ApiController
      include StreamConcern
    end
  end
end
