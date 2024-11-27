<p align='center'>
  <img alt='Black Candy logo' width='200' src='https://raw.githubusercontent.com/blackcandy-org/black_candy/master/app/assets/images/logo.svg'>
</p>

# Black Candy
[![CI](https://github.com/blackcandy-org/black_candy/actions/workflows/ci.yml/badge.svg)](https://github.com/blackcandy-org/black_candy/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/blackcandy-org/blackcandy/badge.svg?branch=master)](https://coveralls.io/github/blackcandy-org/black_candy?branch=master)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
![Docker Pulls](https://img.shields.io/docker/pulls/blackcandy/blackcandy)

![Screenshot](https://raw.githubusercontent.com/blackcandy-org/blackcandy/master/docs/images/screenshot_main.png)

Black Candy is a self-hosted music streaming server, your personal music center.

## Try The Demo

Please visit <https://demo.blackcandy.org> and use demo user (email: admin@admin.com, password: foobar) to log in. And feel free to try it.

> [!NOTE]
> This demo user does not have administrator privileges. So you cannot experience all the features in Black Candy. And all music in the demo are from [Free Music Archive](https://freemusicarchive.org/). You can check their [licenses](https://github.com/blackcandy-org/blackcandy/blob/master/docs/demo_music_licenses.md).

## Installation

Black Candy uses docker image to install easily. You can run Black Candy like this.

```shell
docker run -p 80:80 ghcr.io/blackcandy-org/blackcandy:latest 

# Or pull from Docker Hub.
docker run -p 80:80 blackcandy/blackcandy:latest 
```

That's all. Now, you can access either http://localhost or http://host-ip in a browser, and use initial admin user to log in (email: admin@admin.com, password: foobar).

## Upgrade

> [!IMPORTANT]
> If you upgrade to a major version, you need to read the upgrade guide carefully before upgrade. Because there are some breaking changes in a major version.
>
> - See [V3 Upgrade](https://github.com/blackcandy-org/blackcandy/blob/master/docs/v3_upgrade.md) for upgrade from V2 release.
> - See [Edge Upgrade](https://github.com/blackcandy-org/blackcandy/blob/master/docs/edge_upgrade.md) for upgrade from edge release to latest stable release.

Upgrade Black Candy is pull new image from remote. Then remove an old container and create a new one.

```shell
docker pull ghcr.io/blackcandy-org/blackcandy:latest
docker stop <your_blackcandy_container>
docker rm <your_blackcandy_container>
docker run <OPTIONS> ghcr.io/blackcandy-org/blackcandy:latest 
```

With docker compose, you can upgrade Black Candy like this:

```shell
docker pull ghcr.io/blackcandy-org/blackcandy:latest
docker-compose down
docker-compose up
```

## Mobile Apps

Black Candy mobile apps are available in the following app stores:

[<img src="https://raw.githubusercontent.com/blackcandy-org/ios/master/images/appstore_badge.png" alt="Get it on App Store" height="50">](https://apps.apple.com/app/blackcandy/id6444304071)
[<img src="https://raw.githubusercontent.com/blackcandy-org/android/master/images/fdroid_badge.png" alt="Get it on F-Droid" height="50">](https://f-droid.org/packages/org.blackcandy.android/)


For Android app, you can also download APK from [GitHub Release](https://github.com/blackcandy-org/android/releases/latest)

## Configuration

### Port Mapping

Black Candy exports the 80 port. If you want to be able to access it from the host, you can use the `-p` option to map the port.

```shell
docker run -p 3000:80 ghcr.io/blackcandy-org/blackcandy:latest
```

### Media Files Mounts

You can mount media files from host to container and use `MEDIA_PATH` environment variable to set the media path for black candy.

```shell
docker run -v /media_data:/media_data -e MEDIA_PATH=/media_data ghcr.io/blackcandy-org/blackcandy:latest   
```

### Use PostgreSQL As Database

Black Candy use SQLite as database by default. Because SQLite can simplify the process of installation, and it's an ideal choice for self-hosted small server. If you think SQLite is not enough, or you are using some cloud service like heroku to host Black Candy, you can also use PostgreSQL as database.

```shell
docker run -e DB_ADAPTER=postgresql -e DB_URL=postgresql://yourdatabaseurl ghcr.io/blackcandy-org/blackcandy:latest 
```

### How to Persist Data

All the data that need to persist in Black Candy are stored in `/app/storage`, So you can mount this directory to host to persist data.

```shell
mkdir storage_data

docker run -v ./storage_data:/app/storage ghcr.io/blackcandy-org/blackcandy:latest 
```

### Logging

Black Candy logs to `STDOUT` by default. So if you want to control the log, Docker already supports a lot of options to handle the log in the container. See: https://docs.docker.com/config/containers/logging/configure/.

## Environment Variables

| Name                         | Default   | Description                                                                                                                                                                                                                                                                               |
| ---                          | ---       |-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DB_URL                 |           | The URL of PostgreSQL database. You must set this environment variable if you use PostgreSQL as database.                                                                                                                                                                                 |
| CABLE_DB_URL          |           | The URL of Pub/Sub database. You must set this environment variable if you use PostgreSQL as database.                                                                                                                                                                                    |
| QUEUE_DB_URL                 |           | The URL of background job database. You must set this environment variable if you use PostgreSQL as database.                                                                                                                                                                             |
| CACHE_DB_URL                 |           | The URL of cache database. You must set this environment variable if you use PostgreSQL as database.                                                                                                                                                                                      |
| MEDIA_PATH                   |           | You can use this environment variable to set media path for Black Candy, otherwise you can set media path in settings page.                                                                                                                                                               |
| DB_ADAPTER             | "sqlite"  | There are two adapters are supported, "sqlite" and "postgresql".                                                                                                                                                                                                                          |
| SECRET_KEY_BASE              |           | When the SECRET_KEY_BASE environment variable is not set, Black candy will generate SECRET_KEY_BASE environment variable every time when service start up. This will cause old sessions invalid, You can set your own SECRET_KEY_BASE environment variable on docker service to avoid it. |
| FORCE_SSL                    | false     | Force all access to the app over SSL.                                                                                                                                                                                                                                                     |
| DEMO_MODE                    | false     | Whether to enable demo mode, when demo mode is on, all users cannot access administrator privileges, even user is admin. And also users cannot change their profile.                                                                                                                      |

## Edge Version

The edge version of Black Candy base on master branch, which means it's not stable, you may encounter data loss or other issues. However, I don't recommend normal user using an edge version. But if you are a developer who wants to test or contribute to Black Candy, you can use the edge version.

```shell
docker pull ghcr.io/blackcandy-org/blackcandy:edge
```

## Development

### Requirements

- Ruby 3.3
- Node.js 20
- libvips
- FFmpeg

Make sure you have installed all those dependencies.

### Install gem dependencies

```shell
bundle install
```

### Install JavaScript dependencies

```shell
npm install
```

### Database Configuration

```shell
rails db:prepare
rails db:seed
```

### Start all services

After you’ve set up everything, now you can run `./bin/dev` to start all services you need to develop.
Then visit <http://localhost:3000> use initial admin user to log in (email: admin@admin.com, password: foobar).

### Running tests

```shell
# Running all test
$ rails test:all 

# Running lint
$ rails lint:all
```

## Integrations

Black Candy support get artist and album image from Discogs API. You can create an API token from Discogs and set Discogs token on Setting page to enable it.

## Sponsorship

This project is supported by:

<a href="https://www.digitalocean.com/"><img src="https://opensource.nyc3.cdn.digitaloceanspaces.com/attribution/assets/SVG/DO_Logo_horizontal_blue.svg" width="200px"></a>
<a href="https://www.jetbrains.com/community/opensource"><img src="https://resources.jetbrains.com/storage/products/company/brand/logos/jb_square.svg"></a>
