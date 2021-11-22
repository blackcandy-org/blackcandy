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
    @user = User.create(email: "test@test.com", password: "foobar")
    @user.playlists.create(name: "test")
  end

  test "should have valid email" do
    assert new_user(email: "test1@test.com").valid?

    INVALID_EMAIL_ADDRESSES.each do |email|
      assert_not new_user(email: email).valid?
    end
  end

  test "should downcase email when create" do
    assert_equal "test1@test.com", User.create(email: "TEST1@test.com", password: "foobar").email
  end

  test "should have current playlist after created" do
    assert_equal "CurrentPlaylist", @user.current_playlist.class.name
  end

  test "should have favorite playlist after created" do
    assert_equal "FavoritePlaylist", @user.favorite_playlist.class.name
  end

  test "should retutn all playlists except current playlist and favorite playlist" do
    assert_equal 1, @user.playlists.count
    assert_equal ["Playlist"], @user.playlists.map { |playlist| playlist.class.name }.uniq
  end

  test "should retutn all playlists" do
    all_playlists = @user.all_playlists.map { |playlist| playlist.class.name }.uniq.sort

    assert_equal 3, @user.all_playlists.count
    assert_equal %w[CurrentPlaylist FavoritePlaylist Playlist], all_playlists
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
end
