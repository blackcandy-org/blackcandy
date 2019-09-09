# frozen_string_literal: true

class Artist < ApplicationRecord
  include Searchable

  has_many :albums, dependent: :destroy
  has_many :songs, dependent: :destroy

  mount_uploader :image, ImageUploader

  search_by :name

  def title
    is_unknown? ? I18n.t('text.unknown_artist') : name
  end

  def has_image?
    image.file.present?
  end

  def is_unknown?
    name.blank?
  end

  def need_attach_from_discogs?
    Setting.discogs_token.present? && !has_image? && !is_unknown?
  end
end
