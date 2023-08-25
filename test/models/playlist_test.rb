# frozen_string_literal: true

require "test_helper"

class PlaylistTest < ActiveSupport::TestCase
  test "should have name" do
    assert_not Playlist.new(name: nil, user: users(:admin)).valid?
  end

  test "should raise error when song already in playlist" do
    assert_raises(ActiveRecord::RecordNotUnique) do
      playlists(:playlist1).songs.push songs(:mp3_sample)
    end
  end

  test "should get songs ordered by the position when the song pushed to the playlist" do
    playlist = Playlist.create(name: "test", user: users(:admin))
    playlist.songs.push songs(:flac_sample)
    playlist.songs.push songs(:opus_sample)
    playlist.songs.push songs(:m4a_sample)

    assert_equal %w[flac_sample opus_sample m4a_sample], playlist.reload.songs.pluck(:name)
  end

  test "should replace whole songs" do
    song_ids = Song.where(name: %w[flac_sample opus_sample m4a_sample]).ids
    playlist = playlists(:playlist1)

    assert_changes -> { playlist.reload.song_ids == song_ids }, from: false, to: true do
      playlist.replace(song_ids)
    end
  end

  test "should sort by name" do
    assert_equal %w[playlist1 playlist2], users(:admin).playlists.sort_records(:name).pluck(:name)
    assert_equal %w[playlist2 playlist1], users(:admin).playlists.sort_records(:name, :desc).pluck(:name)
  end

  test "should sort by created_at" do
    assert_equal %w[playlist2 playlist1], users(:admin).playlists.sort_records(:created_at).pluck(:name)
    assert_equal %w[playlist1 playlist2], users(:admin).playlists.sort_records(:created_at, :desc).pluck(:name)
  end

  test "should sort by created_at desc by default" do
    assert_equal %w[playlist1 playlist2], users(:admin).playlists.sort_records.pluck(:name)
  end

  test "should get sort options" do
    assert_equal %w[name created_at], Playlist::SORT_OPTION.values
    assert_equal "created_at", Playlist::SORT_OPTION.default.name
    assert_equal "desc", Playlist::SORT_OPTION.default.direction
  end

  test "should use default sort when use invalid sort value" do
    assert_equal %w[playlist1 playlist2], users(:admin).playlists.sort_records(:invalid).pluck(:name)
  end
end
