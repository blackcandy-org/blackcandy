# Black Candy API Documentation

## Sections

- [Authentication](sections/authentication.md) — sessions, API tokens, logout
- [System](sections/system.md) — server version and minimum supported app version
- [Users](sections/users.md) — listing, creating, updating, and deleting users; updating own profile
- [Sessions](sections/sessions.md) — listing and revoking the sessions of every user
- [Songs](sections/songs.md) — browsing, filtering, and sorting songs
- [Albums](sections/albums.md) — browsing albums and updating cover images
- [Artists](sections/artists.md) — browsing artists and updating cover images
- [Playlists](sections/playlists.md) — managing the user's playlists
- [Playlist songs](sections/playlist_songs.md) — listing, adding, removing, and reordering songs inside a playlist
- [Current playlist](sections/current_playlist.md) — manipulating the playback queue
- [Favorite playlist](sections/favorite_playlist.md) — favoriting and unfavoriting songs
- [Search](sections/search.md) — searching across albums, artists, playlists, and songs

## Authentication

All endpoints require an authenticated token except `POST /sessions` (used to obtain a token) and `GET /system`. See [Authentication](sections/authentication.md) for how to obtain and use an API token.

## Request and response format

Send request bodies as JSON (`Content-Type: application/json`) unless the endpoint accepts a file upload, in which case use `multipart/form-data`. Most write endpoints expect their parameters wrapped in a top-level resource key (e.g. `{ "user": { "email": "…" } }`).

Successful responses return JSON with HTTP status `200 OK`, `201 Created`, or `204 No Content`.

## Errors

Errors are returned with a standard HTTP status code and a JSON body that names the error type and provides a human-readable message:

```json
{
  "type": "RecordInvalid",
  "message": "Email is invalid"
}
```

| Status code | Description |
|-------------|-------------|
| `400 Bad Request` | The request is malformed or violates a business rule |
| `401 Unauthorized` | Authentication is missing or invalid |
| `403 Forbidden` | The authenticated user is not allowed to perform the action |
| `404 Not Found` | The requested resource does not exist or is not visible to the current user |
| `422 Unprocessable Entity` | The submitted data failed validation |
| `429 Too Many Requests` | A rate limit has been exceeded. The response has no body. |
| `500 Internal Server Error` | An unexpected error occurred on the server |

## Pagination

Endpoints that return a collection are paginated unless their section says otherwise. Pagination is controlled by query parameters and surfaced through response headers — the JSON body itself is always a flat array of resources.

| Parameter | Description |
|-----------|-------------|
| `page` | The page number to fetch (1-based). Defaults to `1`. |
| `limit` | The number of items per page. Defaults to `30`, with a maximum of `100`. |

The `Link` header follows the [RFC 8288](https://www.rfc-editor.org/rfc/rfc8288) format:

```
Link: <https://blackcandy.example.com/songs?limit=30&page=1>; rel="first",
      <https://blackcandy.example.com/songs?limit=30&page=1>; rel="prev",
      <https://blackcandy.example.com/songs?limit=30&page=3>; rel="next",
      <https://blackcandy.example.com/songs?limit=30&page=3>; rel="last"
```

`prev` is omitted on the first page; `next` is omitted on the last page.
