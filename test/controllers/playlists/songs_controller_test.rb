# frozen_string_literal: true

require "test_helper"

class Playlists::SongsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @playlist = playlists(:playlist1)
    @user = @playlist.user

    login @user
  end

  test "should show playlist songs" do
    get playlist_songs_url(@playlist)
    assert_response :success
  end

  test "should add songs to playlist" do
    post playlist_songs_url(@playlist), params: { song_id: 3 }
    assert_equal [ 1, 2, 3 ], @playlist.reload.song_ids
  end

  test "should remove songs from playlist" do
    delete playlist_song_url(@playlist, id: 1)
    assert_equal [ 2 ], @playlist.reload.song_ids

    delete playlist_song_url(@playlist, id: 2)
    assert_equal [], @playlist.reload.song_ids
  end

  test "should clear all songs from playlist" do
    delete playlist_songs_url(@playlist)
    assert_equal [], @playlist.reload.song_ids
  end

  test "should reorder songs from playlist" do
    post playlist_songs_url(@playlist), params: { song_id: 3 }
    assert_equal [ 1, 2, 3 ], @playlist.reload.song_ids

    put move_playlist_song_url(@playlist, id: 1), params: { destination_song_id: 2 }

    assert_response :success
    assert_equal [ 2, 1, 3 ], @playlist.reload.song_ids

    put move_playlist_song_url(@playlist, id: 3), params: { destination_song_id: 2 }
    assert_response :success
    assert_equal [ 3, 2, 1 ], @playlist.reload.song_ids
  end

  test "should return not found when reorder song not in playlist" do
    put move_playlist_song_url(@playlist, id: 4), params: { destination_song_id: 2 }
    assert_response :not_found
  end

  test "should has error flash when song alreay in playlist" do
    post playlist_songs_url(@playlist), params: { song_id: 1 }
    assert flash[:alert].present?
  end

  test "should show playlist songs via api" do
    get playlist_songs_url(@playlist), as: :json, headers: api_token_header(@user)

    assert_response :success
    assert_equal @playlist.song_ids, @response.parsed_body.map { |song| song["id"] }
  end

  test "should add songs to playlist via api" do
    post playlist_songs_url(@playlist),
      params: { song_id: 3 },
      as: :json,
      headers: api_token_header(@user)

    assert_response :success
    assert_equal 3, @response.parsed_body["id"]
    assert_equal [ 1, 2, 3 ], @playlist.reload.song_ids
  end

  test "should return error response when song already in playlist via api" do
    post playlist_songs_url(@playlist),
      params: { song_id: 1 },
      as: :json,
      headers: api_token_header(@user)

    assert_response :bad_request
    assert_equal "DuplicatePlaylistSong", @response.parsed_body["type"]
  end

  test "should remove songs from playlist via api" do
    delete playlist_song_url(@playlist, id: 1), as: :json, headers: api_token_header(@user)

    assert_response :success
    assert_equal 1, @response.parsed_body["id"]
    assert_equal [ 2 ], @playlist.reload.song_ids
  end

  test "should clear all songs from playlist via api" do
    delete playlist_songs_url(@playlist), as: :json, headers: api_token_header(@user)

    assert_response :no_content
    assert_equal [], @playlist.reload.song_ids
  end

  test "should reorder songs from playlist via api" do
    put move_playlist_song_url(@playlist, id: 1),
      params: { destination_song_id: 2 },
      as: :json,
      headers: api_token_header(@user)

    assert_response :no_content
    assert_equal [ 2, 1 ], @playlist.reload.song_ids
  end

  test "should paginate index via api with limit param and link header" do
    @playlist.songs.clear
    Song.destroy_all
    songs = 5.times.map { |i| Song.create!(name: "song_#{i}", file_path: "/tmp/song_#{i}.mp3", file_path_hash: "hash_#{i}", md5_hash: "md5_#{i}", artist: artists(:artist1), album: albums(:album1)) }
    songs.each { |song| @playlist.songs.push(song) }

    get playlist_songs_url(@playlist, limit: 2, page: 2), as: :json, headers: api_token_header(@user)

    assert_response :success
    assert_equal 2, @response.parsed_body.size

    links = parse_link_header(@response.headers["link"])

    assert_equal playlist_songs_url(@playlist, limit: 2, page: 1), links["first"]
    assert_equal playlist_songs_url(@playlist, limit: 2, page: 1), links["prev"]
    assert_equal playlist_songs_url(@playlist, limit: 2, page: 3), links["next"]
    assert_equal playlist_songs_url(@playlist, limit: 2, page: 3), links["last"]
  end
end
