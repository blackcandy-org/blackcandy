# Albums

An album groups songs by a primary artist. The `image_urls` field provides three sizes (`small`, `medium`, `large`) of the cover image; if no cover image has been uploaded, these fall back to a placeholder served by the application.

## `GET /albums`

Returns a list of albums.

__Query parameters:__

| Parameter | Description |
|-----------|-------------|
| `filter[year]` | Filter by year |
| `filter[genre]` | Filter by genre |
| `sort` | Sort field: `name`, `year`, `created_at`, `artist_name` |
| `sort_direction` | `asc` (default) or `desc` |

__Response:__

```json
[
  {
    "id": 1,
    "name": "Sample Album",
    "year": 2024,
    "genre": "Rock",
    "artist_id": 1,
    "artist_name": "Sample Artist",
    "image_urls": {
      "small": "https://blackcandy.example.com/rails/active_storage/.../small.jpg",
      "medium": "https://blackcandy.example.com/rails/active_storage/.../medium.jpg",
      "large": "https://blackcandy.example.com/rails/active_storage/.../large.jpg"
    }
  }
]
```

## `GET /albums/:id`

Returns a single album, with its songs embedded under `songs` (each song uses the same shape as in [Songs](songs.md)).

__Response:__

```json
{
  "id": 1,
  "name": "Sample Album",
  "year": 2024,
  "genre": "Rock",
  "artist_id": 1,
  "artist_name": "Sample Artist",
  "image_urls": {
    "small": "...",
    "medium": "...",
    "large": "..."
  },
  "songs": [
    {
      "id": 1,
      "name": "Sample Song",
      "duration": 215.4,
      "album_id": 1,
      "artist_id": 1,
      "url": "https://blackcandy.example.com/stream/new?song_id=1",
      "album_name": "Sample Album",
      "artist_name": "Sample Artist",
      "is_favorited": false,
      "format": "mp3",
      "album_image_urls": { "small": "...", "medium": "...", "large": "..." }
    }
  ]
}
```

## `PATCH /albums/:id`

Updates an album's cover image. Admins only. Because this endpoint accepts a file upload, send the request as `multipart/form-data` rather than JSON.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `album[cover_image]` | file | Yes | A JPEG or PNG image file |

__Response:__

Returns the updated album in the same shape as `GET /albums/:id`.

## `GET /my/recently_played`

Returns the albums the current user has played most recently, newest first. An album is added to this list when it is played through [`PUT /current_playlist/songs/albums/:id`](current_playlist.md#put-current_playlistsongsalbumsid). **Not paginated** — the list holds at most 10 albums.

__Response:__

An array of album objects (same shape as `GET /albums`).
