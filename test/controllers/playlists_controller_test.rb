# frozen_string_literal: true

require "test_helper"

class PlaylistsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get playlists_url

    assert_response :success
  end

  test "should create playlist" do
    playlists_count = Playlist.count

    login
    post playlists_url, params: { playlist: { name: "test" } }, xhr: true

    assert_equal playlists_count + 1, Playlist.count
  end

  test "should create playlist and add song" do
    user = users(:admin)
    song = songs(:mp3_sample)

    login user

    assert_difference -> { user.playlists.count }, 1 do
      post playlists_url, params: { playlist: { name: "test" }, song_id: song.id }, xhr: true
    end

    playlist = user.playlists.order(created_at: :desc).first

    assert_equal [ song.id ], playlist.song_ids
    assert_redirected_to playlist_songs_path(playlist)
  end

  test "should has error flash when failed to create playlist" do
    login
    post playlists_url, params: { playlist: { name: "" } }, xhr: true

    assert flash[:alert].present?
  end

  test "should update playlist" do
    playlist = playlists(:playlist1)
    user = playlist.user

    login user
    patch playlist_url(playlist), params: { playlist: { name: "updated_playlist" } }

    assert_equal "updated_playlist", playlist.reload.name
  end

  test "should has error flash when failed to update playlist" do
    playlist = playlists(:playlist1)
    user = playlist.user

    login user
    patch playlist_url(playlist), params: { playlist: { name: "" } }

    assert flash[:alert].present?
  end

  test "should destroy playlist" do
    playlist = playlists(:playlist1)
    user = playlist.user
    playlists_count = Playlist.count

    login user
    delete playlist_url(playlist)

    assert_equal playlists_count - 1, Playlist.count
  end

  test "should get index via api" do
    user = users(:admin)
    get playlists_url, as: :json, headers: api_token_header(user)
    response = @response.parsed_body

    assert_response :success

    playlist = playlists(:playlist1)
    playlist_response = response.find { |item| item["id"] == playlist.id }

    assert_equal playlist.name, playlist_response["name"]
    assert_equal playlist.user_id, playlist_response["user_id"]
    assert_equal false, playlist_response["is_favorite"]
  end

  test "should create playlist via api" do
    user = users(:admin)

    assert_difference -> { user.playlists.count }, 1 do
      post playlists_url,
        params: { playlist: { name: "new_playlist" } },
        as: :json,
        headers: api_token_header(user)
    end

    assert_response :created
    assert_equal "new_playlist", @response.parsed_body["name"]
    assert_equal user.id, @response.parsed_body["user_id"]
  end

  test "should return error response when failed to create playlist via api" do
    post playlists_url,
      params: { playlist: { name: "" } },
      as: :json,
      headers: api_token_header(users(:admin))

    assert_response :unprocessable_entity
    assert_equal "RecordInvalid", @response.parsed_body["type"]
    assert @response.parsed_body["message"].present?
  end

  test "should update playlist via api" do
    playlist = playlists(:playlist1)

    patch playlist_url(playlist),
      params: { playlist: { name: "updated_playlist" } },
      as: :json,
      headers: api_token_header(playlist.user)

    assert_response :success
    assert_equal "updated_playlist", playlist.reload.name
    assert_equal "updated_playlist", @response.parsed_body["name"]
  end

  test "should return error response when failed to update playlist via api" do
    playlist = playlists(:playlist1)

    patch playlist_url(playlist),
      params: { playlist: { name: "" } },
      as: :json,
      headers: api_token_header(playlist.user)

    assert_response :unprocessable_entity
    assert_equal "RecordInvalid", @response.parsed_body["type"]
    assert @response.parsed_body["message"].present?
  end

  test "should destroy playlist via api" do
    playlist = playlists(:playlist1)

    assert_difference -> { Playlist.count }, -1 do
      delete playlist_url(playlist), as: :json, headers: api_token_header(playlist.user)
    end

    assert_response :no_content
  end

  test "should paginate index via api with limit param and link header" do
    user = users(:admin)
    user.playlists.destroy_all
    5.times { |i| user.playlists.create!(name: "playlist_#{i}") }

    get playlists_url(limit: 2, page: 2), as: :json, headers: api_token_header(user)

    assert_response :success
    assert_equal 2, @response.parsed_body.size

    links = parse_link_header(@response.headers["link"])

    assert_equal playlists_url(limit: 2, page: 1), links["first"]
    assert_equal playlists_url(limit: 2, page: 1), links["prev"]
    assert_equal playlists_url(limit: 2, page: 3), links["next"]
    assert_equal playlists_url(limit: 2, page: 3), links["last"]
  end
end
