# frozen_string_literal: true

class Artist < ApplicationRecord
  include Searchable

  DEFAULT_NAME = 'Unknown Artist'

  validates :name, presence: true

  has_many :albums, dependent: :destroy
  has_many :songs, dependent: :destroy

  has_one_attached :image

  def has_image?
    image.attached?
  end
end
