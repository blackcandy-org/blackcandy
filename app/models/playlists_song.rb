# frozen_string_literal: true

class PlaylistsSong < ApplicationRecord
  belongs_to :playlist
  belongs_to :song

  default_scope { order :position }

  acts_as_list scope: :playlist
end
