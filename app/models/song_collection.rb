# frozen_string_literal: true

class SongCollection < ApplicationRecord
  include Redis::Objects

  after_destroy :delete_redis_keys

  belongs_to :user

  validates :name, presence: true

  set :song_ids

  def playlist
    @playlist ||= Playlist.new(song_ids)
  end

  private

    def delete_redis_keys
      self.class.redis_objects.each do |key, opts|
        redis.del(redis_field_key(key))
      end
    end
end
