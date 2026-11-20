# frozen_string_literal: true

require "test_helper"

class Songs::FavoritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
    @song = songs(:mp3_sample)
  end

  test "should favorite song" do
    login
    post song_favorite_url(@song)

    assert_response :success
    assert @user.favorited?(@song)
  end

  test "should not add a favorited song again" do
    @user.favorite_playlist.songs.push(@song)

    login
    post song_favorite_url(@song)

    assert_response :success
    assert_equal 1, @user.favorite_playlist.playlists_songs.where(song: @song).count
  end

  test "should unfavorite song" do
    @user.favorite_playlist.songs.push(@song)

    login
    delete song_favorite_url(@song)

    assert_response :success
    assert_not @user.favorited?(@song)
  end
end
