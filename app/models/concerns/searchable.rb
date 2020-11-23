# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model
  end

  class_methods do
    def search_by(attr, options = {})
      associations = Array(options[:associations])
      associated_against = associations.index_with { attr }

      search_options = {}.tap do |option|
        option[:against] = attr
        option[:using] = {
          tsearch: { prefix: true },
          trigram: {}
        }
        option[:associated_against] = associated_against if associations.present?
      end

      pg_search_scope "search_by_#{attr}", search_options

      define_singleton_method :search do |query|
        return self if query.blank?

        send("search_by_#{attr}", query)
      end
    end
  end
end
