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
    assert_equal 8, Song.count
  end

  test 'should create associations between artists and albums' do
    assert_equal Album.where(name: %w(album1 album2)).ids.sort, Artist.find_by_name('artist1').albums.ids.sort
    assert_equal Album.where(name: 'album3').ids.sort, Artist.find_by_name('artist2').albums.ids.sort
  end

  test 'should create associations between albums and songs' do
    assert_equal Song.where(name: %w(flac_sample m4a_sample)).ids.sort, Album.find_by_name('album1').songs.ids.sort
    assert_equal Song.where(name: 'mp3_sample').ids.sort, Album.find_by_name('album2').songs.ids.sort
    assert_equal Song.where(name: %w(ogg_sample wav_sample opus_sample oga_sample wma_sample)).ids.sort, Album.find_by_name('album3').songs.ids.sort
  end

  test 'should create associations between artists and songs' do
    assert_equal Song.where(name: %w(flac_sample mp3_sample m4a_sample)).ids.sort, Artist.find_by_name('artist1').songs.ids.sort
    assert_equal Song.where(name: %w(ogg_sample wav_sample opus_sample oga_sample wma_sample)).ids.sort, Artist.find_by_name('artist2').songs.ids.sort
  end

  test 'should change associations when modify album info on file' do
    MediaFile.stub(:file_info, media_file_info_stub(file_fixture('artist1_album2.mp3'), album_name: 'album1')) do
      Media.sync

      assert_equal Album.where(name: 'album1').ids.sort, Artist.find_by_name('artist1').albums.ids.sort
      assert_equal Song.where(name: %w(flac_sample m4a_sample mp3_sample)).ids.sort, Album.find_by_name('album1').songs.ids.sort
    end
  end

  test 'should change associations when modify artist info on file' do
    MediaFile.stub(:file_info, media_file_info_stub(file_fixture('artist1_album2.mp3'), artist_name: 'artist2')) do
      Media.sync

      assert_equal Album.where(name: %w(album2 album3)).ids.sort, Artist.find_by_name('artist2').albums.ids.sort
      assert_equal Song.where(name: %w(mp3_sample ogg_sample wav_sample opus_sample oga_sample wma_sample)).ids.sort, Artist.find_by_name('artist2').songs.ids.sort
    end
  end

  test 'should change song attribute when modify song info on file' do
    MediaFile.stub(:file_info, media_file_info_stub(file_fixture('artist1_album2.mp3'), tracknum: 2)) do
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
      File.delete File.join(tmp_dir, 'artist2_album3.opus')
      File.delete File.join(tmp_dir, 'artist2_album3.oga')
      File.delete File.join(tmp_dir, 'artist2_album3.wma')

      Media.sync

      assert_nil Song.find_by_name('ogg_sample')
      assert_nil Song.find_by_name('wav_sample')
      assert_nil Song.find_by_name('opus_sample')
      assert_nil Song.find_by_name('oga_sample')
      assert_nil Song.find_by_name('wma_sample')
      assert_nil Album.find_by_name('album3')
      assert_nil Artist.find_by_name('artist2')
    end
  end
end
