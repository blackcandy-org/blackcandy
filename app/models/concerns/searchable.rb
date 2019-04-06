# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search_by_name, -> (name) { where('name &@ ?', name) }
  end
end
