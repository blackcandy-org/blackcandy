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

Black candy support mp3, m4a, ogg, oga, opus, flac, wma and wav formats now.

## Installation

Black candy has built [docker images](https://hub.docker.com/r/blackcandy/blackcandy). You can use docker compose to run all services.

First, you should ensure your music files stored under "/media_data" 

Then run: 

```shell
$ curl https://raw.githubusercontent.com/aidewoode/black_candy/v1.1.1/docker-compose.yml > docker-compose.yml
$ docker-compose up -d
```
That's all. Now, you can use initial admin user to login (email: admin@admin.com, password: foobar).

You can also change the `docker-compose.yml` for your own needs.

> **Note:** When the SECRET_KEY_BASE environment variable is not set, Black candy will generate SECRET_KEY_BASE environment variable every time when service start up. 
> This will cause old sessions invalid, You can set your own SECRET_KEY_BASE environment variable on docker service to avoid it.

## Try in PWD

You can try black candy on [Play with Docker](https://labs.play-with-docker.com)

[![Try in PWD](https://raw.githubusercontent.com/play-with-docker/stacks/master/assets/images/button.png)](http://play-with-docker.com/?stack=https://raw.githubusercontent.com/aidewoode/black_candy/master/docker-compose.pwd.yml)

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
