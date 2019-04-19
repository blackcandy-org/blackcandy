# frozen_string_literal: true

class Album < ApplicationRecord
  include Searchable

  validates :name, uniqueness: { scope: :artist }

  has_many :songs, dependent: :destroy
  belongs_to :artist

  has_one_attached :image

  search_by :name, associations: :artist

  def title
    is_unknown? ? I18n.t('text.unknown_album') : name
  end

  def has_image?
    image.attached?
  end

  def is_unknown?
    name.blank?
  end
end
