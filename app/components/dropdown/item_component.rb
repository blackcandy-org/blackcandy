# frozen_string_literal: true

module Dropdown
  class ItemComponent < ApplicationComponent
    def initialize(type, *attributes)
      @type = type
      @attributes = attributes
    end

    def call
      html_options_index = content? ? 1 : 2
      @attributes[html_options_index] = merge_attributes(@attributes[html_options_index], {class: "c-dropdown__item"})

      case @type
      when :link
        content? ? link_to(*@attributes) { content } : link_to(*@attributes)
      when :button
        content? ? button_to(*@attributes) { content } : button_to(*@attributes)
      end
    end
  end
end
