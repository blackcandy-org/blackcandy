# frozen_string_literal: true

class Artist < ApplicationRecord
  include Searchable

  has_many :albums, dependent: :destroy
  has_many :songs, dependent: :destroy

  has_one_attached :image

  search_by :name

  def title
    is_unknown? ? I18n.t('text.unknown_artist') : name
  end

  def has_image?
    image.attached?
  end

  def is_unknown?
    name.blank?
  end
end
