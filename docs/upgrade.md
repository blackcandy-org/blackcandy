# Upgrading Black Candy

## Upgrade from Black Candy v3.0 to v3.1

### Remove Nginx for sending file 

If you are using Nginx to support Sendfile, you can now remove the additional configuration from your Docker Compose file, since BlackCandy has migrated to Thruster's Sendfile support.

First, remove nginx-proxy from your docker-compose.yml.

```diff
- nginx-proxy:
-   image: nginxproxy/nginx-proxy
-   ports:
-     - "80:80"
-   volumes:
-     - ./blackcandy.local:/etc/nginx/vhost.d/blackcandy.local:ro
-     - /var/run/docker.sock:/tmp/docker.sock:ro
-     - /media_data:/media_data #
```
The `NGINX_SENDFILE` environment variable and the `blackcandy.local` file are no longer used. You can remove them.

### Provide Additional Database URLs
> [!NOTE]
> If you are a SQLite user, you don't need to do anything here. 

If you are using PostgreSQL as your database, Since BlackCandy uses separate databases for queue processing, caching, and pub/sub, You will need to provide three additional databases for them. You can create the databases manually. Then, set the CABLE_DB_URL, QUEUE_DB_URL, and CACHE_DB_URL environment variables for BlackCandy.

### Change your port mapping

In version 3.1, BlackCandy changed the default export port from 3000 to 80. This means that after upgrading to v3.1, you need to map 80 instead of 3000. It may look like this:

```
docker run -p 80:80 ghcr.io/blackcandy-org/blackcandy:3.1.0
```

## Upgrade from Black Candy v2.0+ to v3.0

There are a lot of breaking infrastructure changes in Black Candy v3.0, including using SQLite as the default database, removing dependencies on Redis and Sidekiq. We have also removed the dependency on Nginx and Docker Compose to run Black Candy server.

> [!WARNING]
> Because Black Candy v3.0 needs to support both SQLite and PostgreSQL, and some data in v2 is not compatible with SQLite if you upgrade from v2, there is still some small data you will lose after upgrading. Includes all settings.

So depending on whether you want to migrate to SQLite as database in v3.0, you can choose different upgrade methods. You can [keep using PostgreSQL as database](#keep-using-postgresql-as-database) or [migrate to SQLite as database](#migrate-to-sqlite-as-database).

### Keep using PostgreSQL as database

#### Pull the v3.0 image from remote:

```shell
docker pull ghcr.io/blackcandy-org/blackcandy:3.0.0
```

#### Stop and remove the old containers:

```shell
docker-compose down
```

#### Change the docker-compose file to use the new image:

Since v3.0 doesn't depend on redis, sidekiq and nginx, you can remove redis, worker and web service from docker-compose file. Since v3.0 can start the media listener in the settings page, you also need to remove the listener service in the docker-compose file. Remember you should keep the `production_uploads_data` in volumes configuration in the app service, because v3.0 still need this data to migrate to store in new location.

The example docker-compose file is like this:

```yaml
version: '3'
services:
  app:
    container_name: 'blackcandy_app'
    image: ghcr.io/blackcandy-org/blackcandy:v3.0.0 
    ports:
      - "80:3000"
    volumes:
      - ./storage_data:/app/storage
      - /media_data:/media_data
      - production_uploads_data:/app/public/uploads
    environment:
      DB_ADAPTER: postgresql
      DB_URL: postgresql://postgres@postgres/black_candy_production
      MEDIA_PATH: /media_data
    depends_on:
      - postgres
  postgres:
    container_name: 'blackcandy_postgres'
    image: postgres:11.1-alpine
    volumes:
      - production_db_data:/var/lib/postgresql/data
volumes:
  production_db_data:
  production_uploads_data:
``` 

#### Start the new container:

```shell
docker-compose up -d
```

After the new container started, Black Candy will automatically migrate the data from v2 to v3.0.

#### Clean up the unused data:

After the migration, you can remove the old data in v2:

First stop the services:

```shell
docker-compose down
```

Then remove the unused data:

```shell
rm -r media_cache_data
rm -r log
docker volume rm <your_blackcandy_redis_data_volume>
docker volume rm <your_blackcandy_uploads_data_volume>
```

Now you can remove `production_uploads_data` volume in the docker-compose file. The final docker-compose file looks like this:

```yaml

version: '3'
services:
  app:
    container_name: 'blackcandy_app'
    image: ghcr.io/blackcandy-org/blackcandy:v3.0.0 
    ports:
      - "80:3000"
    volumes:
      - ./storage_data:/app/storage
      - /media_data:/media_data
    environment:
      DB_ADAPTER: postgresql
      DB_URL: postgresql://postgres@postgres/black_candy_production
      MEDIA_PATH: /media_data
    depends_on:
      - postgres
  postgres:
    container_name: 'blackcandy_postgres'
    image: postgres:11.1-alpine
    volumes:
      - production_db_data:/var/lib/postgresql/data
volumes:
  production_db_data:
```

#### Restart the services:

```shell
docker-compose up -d
```

### Migrate to SQLite as database

As PostgreSQL data is not compatible with SQLite, you need to export the data from PostgreSQL and cover to SQLite database file.

There are several ways to copy the PostgreSQL data to SQLite. In the following example, I will use [sequel](https://github.com/jeremyevans/sequel) to copy PostgreSQL data to SQLite database file.

#### Stop and remove the old containers:

```shell
docker-compose down
```

#### Cover the PostgreSQL data to SQLite database file:

Make sure you have installed [Ruby](https://www.ruby-lang.org/en/).

```shell
gem install sequel
```

Start a temporary PostgreSQL container for export data:

```shell
docker run -p 5432:5432 -v <your_blackcandy_db_data_volume>:/var/lib/postgresql/data postgres:11.1-alpine
```

Use sequel to export the data to SQLite database file:
```shell
sequel -C postgres://postgres@localhost:5432/black_candy_production sqlite://production.sqlite3
```

Create new storage directory for v3.0, and copy the SQLite database file to it:

```shell 
mkdir storage_data
cp production.sqlite3 storage_data/production.sqlite3
```

### Start the new container to migrate the data:

```shell
docker run -p 3000:3000 -v ./storage_data:/app/storage  -v <your_blackcandy_uploads_data_volume>:/app/public/uploads  ghcr.io/blackcandy-org/blackcandy:v3.0.0 
```

After the new container started, Black Candy will automatically migrate the data from v2 to v3.0.

#### Clean up the unused data:

After the migration, you can remove the old data in v2:

First stop the container:

```shell
docker stop <your_blackcandy_container>
docker rm <your_blackcandy_container>
```

Then remove the unused data:

```shell
rm production.sqlite3
rm -r media_cache_data
rm -r log
docker volume rm <your_blackcandy_redis_data_volume>
docker volume rm <your_blackcandy_uploads_data_volume>
docker volume rm <your_blackcandy_db_data_volume>
```

#### Restart the container:

```shell
docker run -p 3000:3000 -v /media_data:/media_data -v ./storage_data:/app/storage -e MEDIA_PATH=/media_data ghcr.io/blackcandy-org/blackcandy:v3.0.0
```

Now your Black Candy v2 has been upgraded to v3.0, you can go the [README](https://github.com/blackcandy-org/blackcandy/blob/v3.0.0/README.md) to check the configuration options.

## Upgrade from edge release to latest stable release

> [!WARNING]
> You can be only possible to upgrade from edge release to the nearest stable release. For example, if you are using edge release of v3, you can only upgrade to nearest stable v3 release. You cannot upgrade to v4 stable release directly. You can check out the date of your edge release and the stable release to determine which stable release you can upgrade to.

### Upgrade from edge to v3.1

Please check the upgrade guide from [v3.0 to v3.1](#upgrade-from-black-candy-v3.0-to-v3.1) to see if you are missing any steps. Otherwise, you should be fine upgrading from edge to v3.1 

### Upgrade from edge to v3.0

If you are using the latest edge release of v3.0, you should upgrade to the latest stable release of v3.0 directly by pulling the latest v3.0 image from remote.

```shell
docker pull ghcr.io/blackcandy-org/blackcandy:3.0.0
```

However, if you are using the previous edge release of v3.0, you may encounter errors during your upgrade that prevent you from upgrading directly to the latest stable v3.0 release. That's because the migration files have changed to support upgrading from v2 to v3.0, which will cause some particular earlier edge release of v3.0 cannot upgrade directly to stable v3.0. Those errors cannot be solved unless you have some experience working on Rails migration. So I highly recommend you to remove all data in `storage_data` directory and reinstall the latest stable release of v3.0 by following the [README](https://github.com/blackcandy-org/blackcandy/blob/v3.0.0/README.md).

####  Clean up the unused data:

If you have upgraded to the latest stable release of v3.0 successfully, you can remove some unused data you may have in edge release.

Remove unnecessary data in mounted volume if you have:

```shell
rm -r public/uploads #All images assets already migrated  to Active Storage
rm -r storage_data/production_cache.sqlite3* # Previous used by litecache, already migrated to solid_cache 
rm -r storage_data/production_queue.sqlite3* # Previous used by litequeue, already migrated to solid_queue
```

Remove sidekiq and redis config if they are being used.
