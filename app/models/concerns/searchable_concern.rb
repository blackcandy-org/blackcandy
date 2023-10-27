# frozen_string_literal: true

module SearchableConcern
  extend ActiveSupport::Concern

  class_methods do
    def search_by(attr, options = {})
      associations = Hash(options[:associations])
      associations_attrs = associations.map { |name, attr| "#{name}_#{attr}" }
      predicate = [attr].push(*associations_attrs).join("_or_").concat("_i_cont")

      define_singleton_method :ransackable_attributes do |_|
        [attr.to_s]
      end

      define_singleton_method :ransackable_associations do |_|
        associations.keys.map(&:to_s)
      end

      define_singleton_method :search do |query|
        return self if query.blank?

        search_result = ransack({predicate.to_sym => query}).result
        associations.present? ? search_result.includes(*associations.keys) : search_result
      end
    end
  end
end
