# frozen_string_literal: true

module Dropdown
  class ItemComponent < ApplicationComponent
    def initialize(type, *attributes)
      @type = type
      @attributes = attributes
    end

    def call
      html_options_index = content? ? 1 : 2
      html_options = case @type
      when :link
        {class: "c-dropdown__item"}
      when :button
        {form_class: "c-dropdown__item"}
      end

      @attributes[html_options_index] = merge_attributes(@attributes[html_options_index], html_options)

      case @type
      when :link
        content? ? link_to(*@attributes) { content } : link_to(*@attributes)
      when :button
        content? ? button_to(*@attributes) { content } : button_to(*@attributes)
      end
    end
  end
end
