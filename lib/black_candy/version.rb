# frozen_string_literal: true

module BlackCandy
  module Version
    MAJOR = 3
    MINOR = 1
    PATCH = 0
    PRE = nil

    class << self
      def to_s
        return "version: edge(#{commit_hash.first(7)})" if edge_release?
        "v#{version}"
      end

      def link
        return "https://github.com/blackcandy-org/blackcandy/commit/#{commit_hash}" if edge_release?
        "https://github.com/blackcandy-org/blackcandy/releases/tag/v#{version}"
      end

      def commit_hash
        @commit_hash ||= ENV.fetch("COMMIT_HASH", "-------")
      end

      def version
        @version ||= [ MAJOR, MINOR, PATCH, PRE ].compact.join(".")
      end

      private

      def edge_release?
        Rails.root.join(".is-edge-release.txt").exist?
      end
    end
  end
end
