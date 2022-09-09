# frozen_string_literal: true

class Album < ApplicationRecord
  include Searchable
  include Imageable

  validates :name, uniqueness: {scope: :artist}

  has_many :songs, -> { order(:tracknum) }, inverse_of: :album, dependent: :destroy
  belongs_to :artist, touch: true

  search_by :name, associations: :artist

  def title
    is_unknown? ? I18n.t("label.unknown_album") : name
  end

  def is_unknown?
    name.blank?
  end
end
