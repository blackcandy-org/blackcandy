# frozen_string_literal: true

class Song < ApplicationRecord
  validates :name, :file_path, :md5_hash, presence: true

  belongs_to :album
  belongs_to :artist

  def duration
    # the length is the seconds
    minutes = (length / 60) % 60
    seconds = length % 60

    [minutes, seconds].map do |time|
      time.round.to_s.rjust(2, '0')
    end.join(':')
  end

  def format
    MediaFile.format(file_path)
  end

  def favorited?
    Current.user.favorite_playlist.include?(id)
  end
end
