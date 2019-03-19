# frozen_string_literal: true

class Playlist
  def initialize(song_ids)
    self.song_ids = song_ids
  end

  def song_ids=(song_ids)
    raise TypeError, 'Invalid song ids, expect Redis::Set instance' unless song_ids.is_a? Redis::List
    @song_ids = song_ids
  end

  def song_ids
    @song_ids.uniq
  end

  def songs
    Song.includes(:artist).find_ordered(song_ids)
  end

  def push(*song_ids)
    @song_ids.push(*song_ids.flatten)
  end

  def delete(*song_ids)
    song_ids.flatten.each do |song_id|
      @song_ids.delete(song_id)
    end
  end

  def toggle(song_id)
    include?(song_id) ? delete(song_id) : push(song_id)
  end

  def update(attributes)
    case attributes[:update_action]
    when 'push'
      push(attributes[:song_id])
    when 'delete'
      delete(attributes[:song_id])
    end
  end

  def clear
    @song_ids.clear
  end

  def empty?
    @song_ids.empty?
  end

  def include?(song_id)
    @song_ids.include? song_id.to_s
  end

  def count
    @song_ids.size
  end

  def replace(song_ids)
    clear; push(song_ids)
  end
end
