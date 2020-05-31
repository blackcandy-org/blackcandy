<p align='center'>
  <img alt='Black candy logo' width='200' src='app/frontend/images/logo.svg'>
</p>

# Black candy
[![Build status](https://travis-ci.org/aidewoode/black_candy.svg?branch=master)](https://travis-ci.org/aidewoode/black_candy)

Black candy is a self hosted music streaming server built with Rails and Stimulus. The goal of the project is to create a real personal music center.

## Screenshot
![screenshot theme dark](images/screenshot_theme_dark.png)

![screenshot theme light](images/screenshot_theme_light.png)


## Getting started

Black candy use docker for simplify deployment, development and test process. So you should install docker and docker-compose first.

Black candy support mp3, m4a, ogg, opus, flac and wav formats now.

## Installation

Black candy has built [docker images](https://hub.docker.com/r/blackcandy/blackcandy). You can use docker compose to run all services.

First, you should create `docker-compose.yml` file for black candy. 

Here is the example [docker-compose.yml](https://raw.githubusercontent.com/aidewoode/black_candy/v1.1.0/docker-compose.yml) you can use. You can also change the `docker-compose.yml` for your own needs.

Second, set `BLACK_CANDY_MEDIA_PATH` and `BLACK_CANDY_SECRET_KEY_BASE` environment variable on your sever and point `BLACK_CANDY_MEDIA_PATH` to the readable directory on your server to store your music files.

```shell
# Like this
$ export BLACK_CANDY_MEDIA_PATH="/example_media_path"
$ export BLACK_CANDY_SECRET_KEY_BASE="your_secret_key"
```

Finally run:

```shell
$ docker-compose up -d
```

That's all. 

You can use initial admin user to login (email: admin@admin.com, password: foobar).

## Update

Pull new image from remote

```shell
$ docker pull blackcandy/blackcandy
```

Restart services:

```shell
$ docker-compose restart 
```

## Development

```shell
# Clone the repo
$ git clone https://github.com/aidewoode/black_candy.git

# Setup development environment
$ make dev_setup

# Runing development server
$ make dev_run

# Stop development server
$ make dev_stop

# Into development shell
$ make dev_shell
```

## Test

```shell
# Runing test
$ make test_run

# Runing lint
$ make lint_run
```

## Integrations

Black candy support get artist and album image from Discogs API. You can create a API token from Discogs and set Discogs token on Setting page to enable it.
