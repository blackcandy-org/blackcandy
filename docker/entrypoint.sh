#!/bin/sh

# Default to UID and GID 1000 if not provided
USER_ID=${UID:-1000}
GROUP_ID=${GID:-1000}

# Create group and user with the specified IDs
addgroup -g "$GROUP_ID" usergroup
adduser -u "$USER_ID" -G usergroup username

# Change ownership of the working directory
chown -R "$USER_ID":"$GROUP_ID" "$MEDIA_PATH"


if [ -z ${SECRET_KEY_BASE+x} ]; then
  echo "Generating SECRET_KEY_BASE environment variable."
  echo "Please attention, all old sessions will become invalid."
  echo "You can set SECRET_KEY_BASE environment variable on docker service,"
  echo "to avoid generate SECRET_KEY_BASE every time when service start up."
  export SECRET_KEY_BASE=$(rails secret)
fi

exec "$@"
