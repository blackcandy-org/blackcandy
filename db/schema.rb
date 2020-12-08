# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_08_090137) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "albums", force: :cascade do |t|
    t.string "name"
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "artist_id"
    t.index ["artist_id", "name"], name: "index_albums_on_artist_id_and_name", unique: true
    t.index ["artist_id"], name: "index_albums_on_artist_id"
    t.index ["name"], name: "index_albums_on_name"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_various", default: false
    t.index ["name"], name: "index_artists_on_name", unique: true
  end

  create_table "playlists", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "playlists_songs", force: :cascade do |t|
    t.bigint "playlist_id", null: false
    t.bigint "song_id", null: false
    t.integer "position"
    t.index ["song_id", "playlist_id"], name: "index_playlists_songs_on_song_id_and_playlist_id", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.hstore "values"
    t.integer "singleton_guard"
    t.index ["singleton_guard"], name: "index_settings_on_singleton_guard", unique: true
  end

  create_table "songs", force: :cascade do |t|
    t.string "name", null: false
    t.string "file_path", null: false
    t.string "md5_hash", null: false
    t.float "length", default: 0.0, null: false
    t.integer "tracknum"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "album_id"
    t.bigint "artist_id"
    t.index ["album_id"], name: "index_songs_on_album_id"
    t.index ["artist_id"], name: "index_songs_on_artist_id"
    t.index ["name"], name: "index_songs_on_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "is_admin", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.hstore "settings"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
