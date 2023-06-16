# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_06_16_013722) do
  create_table "albums", force: :cascade do |t|
    t.string "name"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "artist_id"
    t.integer "year"
    t.string "genre"
    t.index ["artist_id", "name"], name: "index_albums_on_artist_id_and_name", unique: true
    t.index ["artist_id"], name: "index_albums_on_artist_id"
    t.index ["name"], name: "index_albums_on_name"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_various", default: false
    t.index ["name"], name: "index_artists_on_name", unique: true
  end

  create_table "playlists", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["name"], name: "index_playlists_on_name"
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "playlists_songs", force: :cascade do |t|
    t.integer "playlist_id", null: false
    t.integer "song_id", null: false
    t.integer "position"
    t.index ["song_id", "playlist_id"], name: "index_playlists_songs_on_song_id_and_playlist_id", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.text "values"
    t.integer "singleton_guard"
    t.index ["singleton_guard"], name: "index_settings_on_singleton_guard", unique: true
  end

  create_table "songs", force: :cascade do |t|
    t.string "name", null: false
    t.string "file_path", null: false
    t.string "md5_hash", null: false
    t.float "duration", default: 0.0, null: false
    t.integer "tracknum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "album_id"
    t.integer "artist_id"
    t.string "file_path_hash"
    t.integer "bit_depth"
    t.index ["album_id"], name: "index_songs_on_album_id"
    t.index ["artist_id"], name: "index_songs_on_artist_id"
    t.index ["file_path_hash"], name: "index_songs_on_file_path_hash"
    t.index ["md5_hash"], name: "index_songs_on_md5_hash"
    t.index ["name"], name: "index_songs_on_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password", null: false
    t.boolean "is_admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "settings"
    t.string "password_salt"
    t.string "persistence_token"
    t.string "api_token"
    t.text "recently_played_album_ids"
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["persistence_token"], name: "index_users_on_persistence_token", unique: true
  end

end
