<p align='center'>
  <img alt='Black candy logo' width='200' src='https://raw.githubusercontent.com/aidewoode/black_candy/master/app/assets/images/logo.svg'>
</p>

# Black Candy
[![CI](https://github.com/aidewoode/black_candy/actions/workflows/ci.yml/badge.svg)](https://github.com/aidewoode/black_candy/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/blackcandy-org/black_candy/badge.svg?branch=master)](https://coveralls.io/github/blackcandy-org/black_candy?branch=master)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
![Docker Pulls](https://img.shields.io/docker/pulls/blackcandy/blackcandy)

Black candy is a self hosted music streaming server built with [Rails](https://rubyonrails.org) and [Hotwire](https://hotwired.dev). The goal of the project is to create a real personal music center.

## Screenshot
![screenshot theme dark](https://raw.githubusercontent.com/aidewoode/black_candy/master/screenshots/screenshot_theme_dark.png)

![screenshot theme light](https://raw.githubusercontent.com/aidewoode/black_candy/master/screenshots/screenshot_theme_light.png)


## Getting started

Black candy use docker for simplify deployment, development and test process. So you should install docker and docker-compose first.

Black candy support mp3, m4a, ogg, oga, opus, flac, wma and wav formats now.

## Installation

Black candy has built [docker images](https://hub.docker.com/r/blackcandy/blackcandy). You can use docker compose to run all services.

First, you should ensure your music files stored under "/media_data" 

Then run: 

```shell
$ curl https://raw.githubusercontent.com/aidewoode/black_candy/v2.1.1/docker-compose.yml > docker-compose.yml
$ docker-compose up -d
```
That's all. Now, you can use initial admin user to login (email: admin@admin.com, password: foobar).

You can also change the `docker-compose.yml` for your own needs.

> **Note:** When the SECRET_KEY_BASE environment variable is not set, Black candy will generate SECRET_KEY_BASE environment variable every time when service start up. 
> This will cause old sessions invalid, You can set your own SECRET_KEY_BASE environment variable on docker service to avoid it.

## Try in PWD

[![Try in PWD](https://raw.githubusercontent.com/play-with-docker/stacks/master/assets/images/button.png)](http://play-with-docker.com/?stack=https://raw.githubusercontent.com/aidewoode/black_candy/master/docker-compose.pwd.yml)

Click the button above, then you can try black candy on [Play with Docker](https://labs.play-with-docker.com).

When the service is ready, access black candy from port 80. Then use initial admin user to login (email: admin@admin.com, password: foobar). This demo already contains some sample music file. You can go to the setting page and click the sync button of the media path to import the sample music into the database.

And feel free to try it.

### List for all sample music for the demo:

- Kurt Vile - Live at WFMU on Talk's Cheap 8/11/2008 (licensed under [Attribution-NonCommercial-ShareAlike 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/))		

- Wooden Shjips - Live at ATP NY 2008 (licensed under [Attribution-Noncommercial-No Derivative Works 3.0 United States](http://creativecommons.org/licenses/by-nc-nd/3.0/us/))

- Ty Segall - Live at WFMU on The Cherry Blossom Clinic with Terre T June 25, 2011 (licensed under [Attribution-Noncommercial-No Derivative Works 3.0 United States](http://creativecommons.org/licenses/by-nc-nd/3.0/us/))

- Thee Oh Sees - Peanut Butter Oven EP (licensed under [Attribution-Noncommercial-Share Alike 3.0 United States](http://creativecommons.org/licenses/by-nc-sa/3.0/us/)) 

If like their music, you can buy their albums to support them.


## Upgrade

Pull new image from remote

```shell
$ docker pull blackcandy/blackcandy
```

Restart services:

```shell
$ docker-compose restart 
```

## Development

### Requirements

- Ruby 3.1 
- Postgres 11
- Redis 6.0 
- Nodejs 12
- Yarn
- Imagemagick
- ffmpeg

You can use VS Code Remote Containers or GitHub Codespaces to setup dev environment easily.
For more infomations about dev container, please visit this link <https://code.visualstudio.com/docs/remote/create-dev-container>.

After the dev container has been built. You can run `./bin/dev` in terminal to start all services. 
Then visit <http://localhost:3000> use initial admin user to login (email: admin@admin.com, password: foobar).

## Test

```shell
# Runing test
$ rails test RAILS_ENV=test 

# Runing lint
$ rails lint:all 
```

## Integrations

Black candy support get artist and album image from Discogs API. You can create a API token from Discogs and set Discogs token on Setting page to enable it.
