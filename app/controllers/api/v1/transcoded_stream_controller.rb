# frozen_string_literal: true

module Api
  module V1
    class TranscodedStreamController < ApiController
      include TranscodedStreamConcern
    end
  end
end
