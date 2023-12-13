# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  # From https://en.wikipedia.org/wiki/Email_address#Examples
  INVALID_EMAIL_ADDRESSES = [
    "Abc.example.com",
    'a"b(c)d,e:f;g<h>i[j\k]l@example.com',
    'just"not"right@example.com',
    'this is"not\allowed@example.com',
    'this\ still\"not\\allowed@example.com'
  ].freeze

  setup do
    @user = User.create(email: "test@test.com", password: "foobar", theme: "auto")
    @user.playlists.create(name: "test")
  end

  test "should have valid email" do
    assert User.new(email: "test1@test.com", password: "foobar").valid?

    INVALID_EMAIL_ADDRESSES.each do |email|
      assert_not User.new(email: email, password: "foobar").valid?
    end
  end

  test "password should not less than 6 characters" do
    assert User.new(email: "test1@test.com", password: "foobar").valid?
    assert_not User.new(email: "test1@test.com", password: "foo").valid?
  end

  test "should check password confirmation when it provided" do
    assert User.new(email: "test1@test.com", password: "foobar", password_confirmation: "foobar").valid?
    assert_not User.new(email: "test1@test.com", password: "foobar", password_confirmation: "foo").valid?
  end

  test "should downcase email when create" do
    assert_equal "test1@test.com", User.create(email: "TEST1@test.com", password: "foobar").email
  end

  test "should remove deprecated_password_salt after update password" do
    user = users(:visitor1)
    assert_not_nil user.deprecated_password_salt

    user.update(password: "foobarfoo")
    assert_nil user.reload.deprecated_password_salt
  end

  test "should have current playlist after created" do
    assert_equal "CurrentPlaylist", @user.current_playlist.class.name
  end

  test "should have favorite playlist after created" do
    assert_equal "FavoritePlaylist", @user.favorite_playlist.class.name
  end

  test "should retutn all playlists except current playlist and favorite playlist" do
    assert_equal 1, @user.playlists.count
    assert_equal %w[Playlist], @user.playlists.map { |playlist| playlist.class.name }.uniq
  end

  test "should return all playlist except current playlist" do
    all_playlists = @user.playlists_with_favorite.map { |playlist| playlist.class.name }.uniq.sort

    assert_equal 2, @user.playlists_with_favorite.count
    assert_equal %w[FavoritePlaylist Playlist], all_playlists
  end

  test "should always have current playlist" do
    @user.current_playlist.destroy
    assert_equal "CurrentPlaylist", @user.reload.current_playlist.class.name
  end

  test "should always have favorite playlist" do
    @user.favorite_playlist.destroy
    assert_equal "FavoritePlaylist", @user.reload.favorite_playlist.class.name
  end

  test "should check favorited song" do
    song = songs(:mp3_sample)
    assert_not @user.favorited? song

    @user.favorite_playlist.songs.push song
    assert @user.favorited? song
  end

  test "should add album to recently played" do
    assert_empty @user.recently_played_album_ids

    @user.add_album_to_recently_played albums(:album1)
    assert_equal [albums(:album1).id], @user.recently_played_album_ids
  end

  test "should only add album to recently played once" do
    @user.add_album_to_recently_played albums(:album1)
    @user.add_album_to_recently_played albums(:album2)
    assert_equal [albums(:album2).id, albums(:album1).id], @user.recently_played_album_ids

    @user.add_album_to_recently_played albums(:album1)
    assert_equal [albums(:album1).id, albums(:album2).id], @user.recently_played_album_ids
  end

  test "should get recently played albums on correct position" do
    @user.add_album_to_recently_played albums(:album1)
    @user.add_album_to_recently_played albums(:album2)
    @user.add_album_to_recently_played albums(:album3)
    @user.add_album_to_recently_played albums(:album2)

    assert_equal [albums(:album2), albums(:album3), albums(:album1)], @user.recently_played_albums
  end

  test "should not over the limit of recently played albums" do
    User::RECENTLY_PLAYED_LIMIT.times do |index|
      album = Album.create(name: "album_test_#{index}", artist_id: artists(:artist1).id)
      @user.add_album_to_recently_played album
    end

    @user.add_album_to_recently_played albums(:album1)

    assert_equal User::RECENTLY_PLAYED_LIMIT, @user.recently_played_album_ids.count
  end

  test "should broadcast theme change" do
    assert_no_turbo_stream_broadcasts [@user, :theme] do
      @user.update(theme: "auto")
    end

    assert_turbo_stream_broadcasts [@user, :theme] do
      @user.update(theme: "light")
    end
  end
end
