<p align='center'>
  <img alt='Black Candy logo' width='200' src='https://raw.githubusercontent.com/blackcandy-org/black_candy/master/app/assets/images/logo.svg'>
</p>

# Black Candy
[![CI](https://github.com/blackcandy-org/black_candy/actions/workflows/ci.yml/badge.svg)](https://github.com/blackcandy-org/black_candy/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/blackcandy-org/black_candy/badge.svg?branch=master)](https://coveralls.io/github/blackcandy-org/black_candy?branch=master)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
![Docker Pulls](https://img.shields.io/docker/pulls/blackcandy/blackcandy)

Black Candy is a self hosted music streaming server built with [Rails](https://rubyonrails.org) and [Hotwire](https://hotwired.dev). The goal of the project is to create a real personal music center.

## Screenshot
![screenshot theme dark](https://raw.githubusercontent.com/blackcandy-org/black_candy/master/screenshots/screenshot_theme_dark.png)

![screenshot theme light](https://raw.githubusercontent.com/blackcandy-org/black_candy/master/screenshots/screenshot_theme_light.png)

## Try The Demo

Please visit <https://demo.blackcandy.org> and use demo user (email: admin@admin.com, password: foobar) to login. And feel free to try it.

> **Notice:** This demo user does not have administrator privileges. So you cannot experience all the features in Black Candy. And all music in the demo is under non-commercial licences. You can check their [licences](https://github.com/blackcandy-org/black_candy#licences-of-the-music-in-demo).

## Installation
> ⚠️  **Notice:** This installation instruction is for edge version, which means the docker image is build base on master branch. Because upcoming major version of Black Candy is going to have a lot of infrastructure changes. So the installation process will have a lot of difference.
> If you are looking for installation instruction for latest stable version, please visit [here](https://github.com/blackcandy-org/black_candy/blob/7f9202bd8a9777d439e95eabd0654e9b4a336be9/README.md).

Black Candy use docker image to install easily. You can simply run Black Candy like this.

```shell
docker run -p 3000:3000 ghcr.io/blackcandy-org/blackcandy:edge 
```

That's all. Now, you can access either http://localhost:3000 or http://host-ip:3000 in a browser, and use initial admin user to login (email: admin@admin.com, password: foobar).

## Mobile App
Black Candy now has an iOS app in beta. You can visit [here](https://testflight.apple.com/join/TwMUVmDl) and join TestFlight to give it a try. Because this iOS app still in beta, you need use the edge version of Black Candy.

## Configuration

### Port Mapping

Black Candy exports the 3000 port. If you want to be able to access it from the host, you can use the `-p` option to map the port. 

```shell
docker run -p 3000:3000 ghcr.io/blackcandy-org/blackcandy:edge
```

### Media Files Mounts 

You can mount media files from host to container and use `MEDIA_PATH` environment variable to set the media path for black candy.

```shell
docker run -v /media_data:/media_data -e MEDIA_PATH=/media_data ghcr.io/blackcandy-org/blackcandy:edge   
```

### Use PostgreSQL As Database

Black Candy use SQLite as database by default. Because SQLite can simplify the process of installation, and it's an ideal choice for self hosted small server. If you think SQLite is not enough or you are using some cloud service like heroku to host Black Candy, you can also use PostgreSQL as database.

```shell
docker run -e DB_ADAPTER=postgresql -e DB_URL=postgresql://yourdatabaseurl ghcr.io/blackcandy-org/blackcandy:edge 
```

### How to Persist Data

All the data that need to persist in Black Candy are stored in `/app/storage`, So you can mount this directory to host to persist data.

```shell
mkdir storage_data

docker run -v ./storage_data:/app/storage ghcr.io/blackcandy-org/blackcandy:edge 
```

### Nginx To Send File

Black Candy supports use Nginx to delivery audio file to client. It's a more effective way than handle by Black Candy backend. And Black Candy docker image are also ready for [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy), which means you can setup a Nginx proxy for Black Candy easily. I recommend you use [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) with Black Candy.

You can use docker-compose to setup those services. The docker-compose.yml file looks like this:

```yaml
version: '3'

services:
  nginx-proxy:
    image: nginxproxy/nginx-proxy
    ports:
      - "80:80"
    volumes:
      - ./blackcandy.local:/etc/nginx/vhost.d/blackcandy.local:ro
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - /media_data:/media_data # Keep the path of media files in container same as blackcandy container.

  app:
    image: ghcr.io/blackcandy-org/blackcandy:edge 
    volumes:
      - ./storage_data:/app/storage
      - /media_data:/media_data
    environment:
      VIRTUAL_HOST: blackcandy.local
      MEDIA_PATH: /media_data
      NGINX_SENDFILE: "true" # Don't forget to set `NGINX_SENDFILE` environment variable to true to enable nginx sendfile.
```

```shell
# Get the default sendfile config for blackcandy. This file need to mount to nginx proxy container to add custom configuration for nginx.
curl https://raw.githubusercontent.com/blackcandy-org/black_candy/master/config/nginx/sendfile.conf > blackcandy.local 

docker-compose up
```

### Logging

Black Candy logs to `STDOUT` by default. So if you want to control the log, Docker already supports a lot of options to handle the log in the container. see: https://docs.docker.com/config/containers/logging/configure/.

## Environment Variables

| Name                         | Default   | Description |
| ---                          | ---       | ---         |
| DB_URL                 |           | The URL of PostgreSQL database. You must set this environment variable if you use PostgreSQL as database. |
| MEDIA_PATH                   |           | You can use this environment variable to set media path for Black Candy, otherwise you can set media path in settings page. |
| DB_ADAPTER             | "sqlite"  | There are two adapters are supported, "sqlite" and "postgresql".|
| NGINX_SENDFILE               | false     | Whether enable Nginx sendfile. |
| SECRET_KEY_BASE              |           | When the SECRET_KEY_BASE environment variable is not set, Black candy will generate SECRET_KEY_BASE environment variable every time when service start up. This will cause old sessions invalid, You can set your own SECRET_KEY_BASE environment variable on docker service to avoid it. |
| FORCE_SSL                    | false     | Force all access to the app over SSL. |
| DEMO_MODE                    | false     | Whether to enable demo mode, when demo mode is on, all users cannot access administrator privileges, even user is admin. And also users cannot change their profile.  |

## Upgrade

Pull new image from remote

```shell
$ docker pull ghcr.io/blackcandy-org/blackcandy:edge 
```

## Development

### Requirements

- Ruby 3.2
- Node.js 20
- Yarn
- libvips
- FFmpeg

Make sure you have installed all those dependencies.

### Install gem dependencies

```shell
bundle install
```

### Install JavaScript dependencies

```shell
yarn install
```

### Database Configuration

```shell
rails db:prepare
rails db:seed
```

### Start all services

After you’ve set up everything, now you can running `./bin/dev` to start all service you need to develop.
Then visit <http://localhost:3000> use initial admin user to login (email: admin@admin.com, password: foobar).


## Test

```shell
# Running all test
$ rails test:all 

# Running lint
$ rails lint:all
```

## Integrations

Black Candy support get artist and album image from Discogs API. You can create a API token from Discogs and set Discogs token on Setting page to enable it.

## Licences Of The Music In Demo 

- Kurt Vile - Live at WFMU on Talk's Cheap 8/11/2008 (licensed under [Attribution-NonCommercial-ShareAlike 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/))

- Wooden Shjips - Live at ATP NY 2008 (licensed under [Attribution-Noncommercial-No Derivative Works 3.0 United States](http://creativecommons.org/licenses/by-nc-nd/3.0/us/))

- Ty Segall - Live at WFMU on The Cherry Blossom Clinic with Terre T June 25, 2011 (licensed under [Attribution-Noncommercial-No Derivative Works 3.0 United States](http://creativecommons.org/licenses/by-nc-nd/3.0/us/))

- Thee Oh Sees - Peanut Butter Oven EP (licensed under [Attribution-Noncommercial-Share Alike 3.0 United States](http://creativecommons.org/licenses/by-nc-sa/3.0/us/))

If you like their music, you can buy their albums to support them.


## Sponsorship 

This project is supported by:

<a href="https://www.digitalocean.com/"><img src="https://opensource.nyc3.cdn.digitaloceanspaces.com/attribution/assets/SVG/DO_Logo_horizontal_blue.svg" width="200px"></a>
<a href="https://www.jetbrains.com/community/opensource"><img src="https://resources.jetbrains.com/storage/products/company/brand/logos/jb_square.svg"></a>