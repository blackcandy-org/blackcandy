# frozen_string_literal: true

class DropdownComponent < ApplicationComponent
  renders_one :toggle
  renders_many :menu, types: {
    item: Dropdown::ItemComponent,
    divider: -> { tag :hr }
  }

  def initialize(**attributes)
    @attributes = attributes
    @attributes[:class] = class_names(@attributes[:class], "c-dropdown")
    @attributes[:data] = merge_attributes(@attributes[:data], {controller: "dropdown"})
  end
end
