# frozen_string_literal: true

class Album < ApplicationRecord
  include SearchableConcern
  include ImageableConcern
  include FilterableConcern
  include SortableConcern

  validates :name, uniqueness: {scope: :artist}

  has_many :songs, -> { order(:tracknum) }, inverse_of: :album, dependent: :destroy
  belongs_to :artist, touch: true

  search_by :name, associations: {artist: :name}

  filter_by :year, :genre

  sort_by :name, :year, :created_at
  sort_by_associations artist: :name

  def title
    is_unknown? ? I18n.t("label.unknown_album") : name
  end

  def is_unknown?
    name.blank?
  end
end
