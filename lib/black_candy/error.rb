# frozen_string_literal: true

module BlackCandy
  module Error
    class Forbidden < StandardError; end

    class NotFound < StandardError; end

    class InvalidFilePath < StandardError; end
  end
end
