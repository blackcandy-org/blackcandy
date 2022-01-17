#!/bin/sh

if [ -z ${SECRET_KEY_BASE+x} ]; then
  echo "Generating SECRET_KEY_BASE environment variable."
  echo "Please attention, all old sessions will become invalid."
  echo "You can set SECRET_KEY_BASE environment variable on docker service,"
  echo "to avoid generate SECRET_KEY_BASE every time when service start up."
  export SECRET_KEY_BASE=$(rails secret)
fi

exec "$@"
