# Current playlist

The current playlist is the per-user playback queue. There is exactly one current playlist per user, accessed without an ID. Endpoints mirror the regular [Playlist songs](playlist_songs.md) endpoints, but with extras for inserting near a "now playing" song and for replacing the queue from an album or another playlist in one call.

Songs in responses use the same shape as in [Songs](songs.md).

## `GET /current_playlist/songs`

Returns every song in the current playlist, in queue order. **Not paginated** — the entire queue is returned in a single response.

__Response:__

```json
[
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
```

## `POST /current_playlist/songs`

Adds a song to the current playlist. Position depends on the optional parameters:

- With `location=last`, append to the end.
- With `current_song_id`, insert directly after the named song (the "now playing" song).
- With neither, insert at the start of the queue.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `song_id` | integer | Yes | The ID of the song to add |
| `current_song_id` | integer | No | Insert immediately after this song |
| `location` | string | No | Set to `last` to append to the end of the queue |

__Request:__

```json
{
  "song_id": 4,
  "current_song_id": 1
}
```

__Response:__

Returns the added song.

## `DELETE /current_playlist/songs/:id`

Removes a single song from the queue.

__Response:__

Returns the removed song.

## `DELETE /current_playlist/songs`

Empties the queue.

__Response:__

Returns `204 No Content` on success.

## `PUT /current_playlist/songs/:id/move`

Reorders a song so that it takes the position currently held by `destination_song_id`.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `destination_song_id` | integer | Yes | The ID of the song whose position to take |

__Request:__

```json
{
  "destination_song_id": 2
}
```

__Response:__

Returns `204 No Content` on success.

## `PUT /current_playlist/songs/albums/:id`

Replaces the queue with every song from the given album, in album order. The album is also added to the user's [recently played](albums.md#get-myrecently_played) list.

__Response:__

Returns the new queue contents (an array of songs).

## `PUT /current_playlist/songs/playlists/:id`

Replaces the queue with every song from the given playlist, in playlist order. The playlist must be visible to the current user (owned by them, or the favorite playlist).

__Response:__

Returns the new queue contents (an array of songs).
