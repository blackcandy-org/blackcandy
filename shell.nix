with import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/e55f77277b59fabd3c220f4870a44de705b1babb.tar.gz") {};

mkShell {
  buildInputs = [
    ruby
    postgresql_11
    redis
    nodejs-12_x
    yarn
    imagemagick7
    ffmpeg
    libxml2
    libxslt
  ];

  shellHook = ''
    export GEM_HOME=$PWD/.gems
    export GEM_PATH=$GEM_HOME
    export PATH=$GEM_HOME/bin:$PATH
    export PGDATA=$PWD/.pg_data
    export REDISDATA=$PWD/.redis_data
    export DB_USER=postgres
    export DB_HOST=localhost
    export REDIS_SIDEKIQ_URL=redis://localhost:6379/1

    bundle config build.nokogiri --use-system-libraries

    if [ ! -d $REDISDATA ]; then
      mkdir -p $REDISDATA
    fi

    if [ ! -d $PGDATA ]; then
      initdb -U postgres $PGDATA
    fi
  '';
}
