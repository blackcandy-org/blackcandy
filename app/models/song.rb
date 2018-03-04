class Song < ApplicationRecord
  require 'mp3info'

  before_create :set_song_info, :create_associations

  has_one_attached :media

  belongs_to :user
  belongs_to :album, optional: true

  def duration
    # the length is the seconds
    minutes = (length / 60) % 60
    seconds = length % 60

    [minutes, seconds].map do |time|
      time.round.to_s.rjust(2, '0')
    end.join(':')
  end

  private

  def set_song_info
    Mp3Info.open(StringIO.new(media.attachment.blob.download)) do |song_info|
      create_song_attributes(song_info)
    end
  end

  def create_song_attributes(song_info)
    song_tag = song_info.tag

    self.name = get_song_info(song_tag, :title) || media.filename.to_s
    self.album_name = get_song_info(song_tag, :album) || I18n.t('default.album_name')
    self.artist_name = get_song_info(song_tag, :artist) || I18n.t('default.artist_name')

    self.tracknum = song_tag.tracknum
    self.length = song_info.length
  end

  def create_associations
    artist = Artist.create_or_find_from_song(self)
    album = Album.create_or_find_from_song(self)

    artist.add_album(album)
    album.add_song(self)
  end

  def get_song_info(tag, attr_name)
    tag.send(attr_name)&.strip.presence
  end
end
