# frozen_string_literal: true

require "test_helper"

class ArtistTest < ActiveSupport::TestCase
  test "should have default name when name is empty" do
    artist = Artist.create(name: nil)

    assert artist.unknown?
    assert_equal "Unknown Artist", artist.name
  end

  test "should have default name when is various artist" do
    artist = Artist.create(various: true)

    assert artist.various?
    assert_equal "Various Artists", artist.name
  end

  test "should get all albums" do
    assert_equal Album.where(name: %w[album1 album2 album4]).ids.sort, artists(:artist1).all_albums.ids.sort
  end

  test "should get appears on albums" do
    assert_equal Album.where(name: %w[album4]).ids.sort, artists(:artist1).appears_on_albums.ids.sort
  end

  test "should sort by name" do
    assert_equal %w[artist1 artist2 various_artists], Artist.sort_records(:name).pluck(:name).compact
    assert_equal %w[various_artists artist2 artist1], Artist.sort_records(:name, :desc).pluck(:name).compact
  end

  test "should sort by created_at" do
    assert_equal %w[artist2 artist1 various_artists], Artist.sort_records(:created_at).pluck(:name).compact
    assert_equal %w[various_artists artist1 artist2], Artist.sort_records(:created_at, :desc).pluck(:name).compact
  end

  test "should sort by name by default" do
    assert_equal %w[artist1 artist2 various_artists], Artist.sort_records.pluck(:name).compact
  end

  test "should get sort options" do
    assert_equal %w[name created_at], Artist::SORT_OPTION.values
    assert_equal "name", Artist::SORT_OPTION.default.name
    assert_equal "asc", Artist::SORT_OPTION.default.direction
  end

  test "should use default sort when use invalid sort value" do
    assert_equal %w[artist1 artist2 various_artists], Artist.sort_records(:invalid).pluck(:name).compact
  end

  test "should transform cover image after attached" do
    artist = artists(:artist1)
    artist.cover_image.attach(
      io: StringIO.new(file_fixture("cover_image.jpg").read),
      filename: "cover.jpg",
      content_type: "image/jpeg"
    )

    assert artist.cover_image.variant(:medium).send(:processed?)
  end
end
