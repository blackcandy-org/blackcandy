# frozen_string_literal: true

require 'application_system_test_case'

class AlbumTest < ApplicationSystemTestCase
  setup do
    @album = albums(:album1)
    login_as users(:visitor1)
  end

  test 'show album' do
    visit album_url(@album)

    assert_text(@album.name)
    assert_text(@album.artist.name)

    @album.songs.each do |song|
      assert_text(song.name)
    end
  end
end
