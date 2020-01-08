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

ActiveRecord::Schema.define(version: 2020_01_02_034003) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgroonga"
  enable_extension "plpgsql"

  create_table "albums", force: :cascade do |t|
    t.string "name"
    t.integer "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.index ["artist_id"], name: "index_albums_on_artist_id"
    t.index ["name"], name: "pgroonga_index_albums_on_name", opclass: :pgroonga_varchar_full_text_search_ops, using: :pgroonga
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.index ["name"], name: "index_artists_on_name", unique: true
    t.index ["name"], name: "pgroonga_index_artists_on_name", opclass: :pgroonga_varchar_full_text_search_ops, using: :pgroonga
  end

  create_table "playlists", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "playlists_songs", id: false, force: :cascade do |t|
    t.bigint "song_id"
    t.bigint "playlist_id"
    t.datetime "created_at", null: false
    t.index ["playlist_id"], name: "index_playlists_songs_on_playlist_id"
    t.index ["song_id", "playlist_id"], name: "index_playlists_songs_on_song_id_and_playlist_id", unique: true
    t.index ["song_id"], name: "index_playlists_songs_on_song_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "songs", force: :cascade do |t|
    t.string "name", null: false
    t.string "file_path", null: false
    t.string "md5_hash", null: false
    t.float "length", default: 0.0, null: false
    t.integer "tracknum"
    t.integer "album_id"
    t.integer "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_songs_on_album_id"
    t.index ["artist_id"], name: "index_songs_on_artist_id"
    t.index ["name"], name: "pgroonga_index_songs_on_name", opclass: :pgroonga_varchar_full_text_search_ops, using: :pgroonga
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "is_admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
