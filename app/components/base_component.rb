# frozen_string_literal: true

class BaseComponent < ApplicationComponent
  def initialize(tag = :div, **attributes)
    @tag = tag
    @tag_args = attributes

    test_id = @tag_args.delete(:test_id)
    @tag_args[:data] = merge_attributes(@tag_args[:data], {test_id: test_id}) if test_id
  end

  def call
    content? ? content_tag(@tag, content, @tag_args) : tag(@tag, @tag_args)
  end
end
