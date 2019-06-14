# frozen_string_literal: true

require 'test_helper'

class MediaTest < ActiveSupport::TestCase
  setup do
    clear_media_data

    Setting.media_path = Rails.root.join('test', 'fixtures', 'files')
    Media.sync
  end

  test 'should create all records in database when synced' do
    assert_equal 2, Artist.count
    assert_equal 3, Album.count
    assert_equal 5, Song.count
  end

  test 'should create associations between artists and albums' do
    assert_equal Album.where(name: %w(album1 album2)), Artist.find_by_name('artist1').albums
    assert_equal Album.where(name: 'album3'), Artist.find_by_name('artist2').albums
  end

  test 'should create associations between albums and songs' do
    assert_equal Song.where(name: %w(flac_sample m4a_sample)), Album.find_by_name('album1').songs
    assert_equal Song.where(name: 'mp3_sample'), Album.find_by_name('album2').songs
    assert_equal Song.where(name: %w(ogg_sample wav_sample)), Album.find_by_name('album3').songs
  end

  test 'should create associations between artists and songs' do
    assert_equal Song.where(name: %w(flac_sample mp3_sample m4a_sample)), Artist.find_by_name('artist1').songs
    assert_equal Song.where(name: %w(ogg_sample wav_sample)), Artist.find_by_name('artist2').songs
  end

  test 'should change associations when modify album info on file' do
    create_tmp_dir(from: Setting.media_path) do |tmp_dir|
      Setting.media_path = tmp_dir
      update_media_tag File.join(tmp_dir, 'artist1_album2.mp3'), album: 'album1'

      Media.sync

      assert_equal Album.where(name: 'album1'), Artist.find_by_name('artist1').albums
      assert_equal Song.where(name: %w(flac_sample m4a_sample mp3_sample)), Album.find_by_name('album1').songs
    end
  end

  test 'should change associations when modify artist info on file' do
    create_tmp_dir(from: Setting.media_path) do |tmp_dir|
      Setting.media_path = tmp_dir
      update_media_tag File.join(tmp_dir, 'artist1_album2.mp3'), artist: 'artist2'

      Media.sync

      assert_equal Album.where(name: %w(album2 album3)), Artist.find_by_name('artist2').albums
      assert_equal Song.where(name: %w(mp3_sample ogg_sample wav_sample)), Artist.find_by_name('artist2').songs
    end
  end

  test 'should change song attribute when modify song info on file' do
    create_tmp_dir(from: Setting.media_path) do |tmp_dir|
      Setting.media_path = tmp_dir
      update_media_tag File.join(tmp_dir, 'artist1_album2.mp3'), track: 2

      assert_changes -> { Song.find_by_name('mp3_sample').tracknum }, from: 1, to: 2 do
        Media.sync
      end
    end
  end

  test 'should clear records on database when delete file' do
    create_tmp_dir(from: Setting.media_path) do |tmp_dir|
      Setting.media_path = tmp_dir

      File.delete File.join(tmp_dir, 'artist2_album3.ogg')
      File.delete File.join(tmp_dir, 'artist2_album3.wav')

      Media.sync

      assert_nil Song.find_by_name('ogg_sample')
      assert_nil Song.find_by_name('wav_sample')
      assert_nil Album.find_by_name('album3')
      assert_nil Artist.find_by_name('artist2')
    end
  end
end
