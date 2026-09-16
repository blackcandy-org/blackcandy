# Sessions

A session is created every time a user signs in, and lives until it is revoked or the user signs out.

See [Authentication](authentication.md) for creating a session (`POST /sessions`) and for signing out of the current one (`DELETE /my/session`).

## `GET /sessions`

Returns every session on the server — the session making the request first, then the rest newest first. Admins only. **Not paginated** — every session is returned in a single response.

__Response:__

```json
[
  {
    "id": 8,
    "user_id": 2,
    "ip_address": "10.0.0.4",
    "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15",
    "created_at": "2026-09-15T02:31:05.271Z",
    "email": "alice@example.com",
    "is_current": true
  },
  {
    "id": 5,
    "user_id": 3,
    "ip_address": "10.0.0.7",
    "user_agent": "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 Black Candy Android/1.0",
    "created_at": "2026-09-11T18:02:44.109Z",
    "email": "bob@example.com",
    "is_current": false
  }
]
```

## `DELETE /sessions/:id`

Revokes a session. Admins only. The session making the request cannot be revoked — use [`DELETE /my/session`](authentication.md#delete-mysession) to sign out instead.

__Response:__

Returns `204 No Content` on success, or `403 Forbidden` when the session is the one making the request.
