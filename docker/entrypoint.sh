#!/usr/bin/env sh

# Useful shorthand variables
USER_NAME=$APP_USER
USER_ID=${LOCAL_USER_ID:-9001}

# Add user if it doesn't exists
if ! id -u "$USER_NAME" 2> /dev/null; then
  adduser -s /bin/sh -u "$USER_ID" -D "$USER_NAME"
fi

# Change ownership of library directories
mkdir -p "$GEM_HOME/gems/bin"
chown -R "$USER_NAME:$USER_NAME" /usr/local/bundle
chown -R "$USER_NAME:$USER_NAME" "$GEM_HOME/bin"
chown -R "$USER_NAME:$USER_NAME" "$GEM_HOME/gems/bin"
chown -R "$USER_NAME:$USER_NAME" /app

# Fake home direcotry
export HOME=/home/$USER_NAME

# Use container set paths
# https://bundler.io/v1.16/guides/bundler_docker_guide.html
unset BUNDLE_PATH
unset BUNDLE_BIN

# Run the command attached to the process with PID 1 so that signals get
# passed to the process/app being run
exec /usr/local/sbin/pid1 -u "$USER_NAME" -g "$USER_NAME" "$@"
