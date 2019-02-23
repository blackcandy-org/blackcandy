# frozen_string_literal: true

class Playlist
  def initialize(song_ids)
    self.song_ids = song_ids
  end

  def song_ids=(song_ids)
    raise TypeError, 'Invalid song ids, expect Redis::Set instance' unless song_ids.is_a? Redis::Set
    @song_ids = song_ids
  end

  def songs
    Song.where(id: @song_ids.to_a)
  end

  def push(song_id)
    @song_ids << song_id.to_i
  end

  def delete(song_id)
    @song_ids.delete(song_id.to_i)
  end

  def clear
    @song_ids.clear
  end
end
