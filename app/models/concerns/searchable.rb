# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model
  end

  class_methods do
    def search_by(attr, options = {})
      associations = Array(options[:associations])
      associated_against = Hash[associations.map { |association| [association, attr] }]

      search_options = {}.tap do |option|
        option[:against] = attr
        option[:using] = {
          tsearch: { prefix: true },
          trigram: {}
        }
        option[:associated_against] = associated_against unless associations.blank?
      end

      pg_search_scope "search_by_#{attr}", search_options

      define_singleton_method :search do |query|
        return self unless query.present?
        send("search_by_#{attr}", query)
      end
    end
  end
end
