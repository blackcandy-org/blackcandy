# frozen_string_literal: true

module BlackCandy
  module Version
    MAJOR = 3
    MINOR = 0
    PATCH = 0
    PRE = ""

    def self.to_s
      return "Edge" if Rails.root.join(".is-edge-release.txt").exist?
      [MAJOR, MINOR, PATCH, PRE].compact.join(".")
    end
  end
end
