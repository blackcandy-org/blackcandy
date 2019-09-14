# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search_by(attr, options = {})
      define_singleton_method :search do |query|
        return self unless query.present?

        associations = Array(options[:associations]).map(&:to_sym)

        if associations.blank?
          where(sanitize_sql_for_conditions ["#{attr} &@ ?", query])
        else
          associations_query = associations.map do |association|
            "#{association.to_s.pluralize}.#{attr} &@ ?"
          end.join(' OR ')

          query_conditions = sanitize_sql_for_conditions ["#{self.table_name}.#{attr} &@ ? OR #{associations_query}", *Array.new(associations.length + 1, query)]

          joins(associations).where(query_conditions)
        end
      end
    end
  end
end
