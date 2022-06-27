with import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7feed2c0bec4161c83509d18089784cfcef49667.tar.gz") {};

mkShell {
  buildInputs = [
    ruby_3_1
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
    export REDIS_DATA_URL=redis://localhost:6379/0
    export REDIS_SIDEKIQ_URL=redis://localhost:6379/1
    export REDIS_CABLE_URL=redis://localhost:6379/2

    bundle config build.nokogiri --use-system-libraries

    if [ ! -d $REDISDATA ]; then
      mkdir -p $REDISDATA
    fi

    if [ ! -d $PGDATA ]; then
      initdb -U postgres $PGDATA
    fi
  '';
}
