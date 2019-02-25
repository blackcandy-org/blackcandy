# frozen_string_literal: true

module Playlistable
  extend ActiveSupport::Concern

  included do
    include Redis::Objects
    after_destroy :delete_redis_keys
  end

  class_methods do
    def has_playlist
      set :song_ids

      define_method :playlist do
        @playlist ||= Playlist.new(song_ids)
      end
    end

    def has_playlists(*names)
      names.each do |name|
        set "#{name}_song_ids"

        define_method "#{name}_playlist" do
          instance_variable_get("@#{name}_playlist") ||
            instance_variable_set("@#{name}_playlist", Playlist.new(send("#{name}_song_ids")))
        end
      end
    end
  end

  private

    def delete_redis_keys
      self.class.redis_objects.each do |key, opts|
        redis.del(redis_field_key(key))
      end
    end
end
