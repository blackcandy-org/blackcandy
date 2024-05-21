# Upgrade from edge release to latest stable release

> [!WARNING]
> You can be only possible to upgrade from edge release to the nearest stable release. For example, if you are using edge release of v3, you can only upgrade to nearest stable v3 release. You cannot upgrade to v4 stable release directly. You can check out the date of your edge release and the stable release to determine which stable release you can upgrade to.

## Upgrade from edge to v3

If you are using the latest edge release of v3, you should upgrade to the latest stable release of v3 directly by pulling the latest v3 image from remote.

```shell
docker pull ghcr.io/blackcandy-org/blackcandy:3.0.0
```

However, if you are using the previous edge release of v3, you may encounter errors during your upgrade that prevent you from upgrading directly to the latest stable v3 release. That's because the migration files have changed to support upgrading from v2 to v3, which will cause some particular earlier edge release of v3 cannot upgrade directly to stable v3. Those errors cannot be solved unless you have some experience working on Rails migration. So I highly recommend you to remove all data in `storage_data` directory and reinstall the latest stable release of v3 by following the [README](https://github.com/blackcandy-org/blackcandy/blob/v3.0.0/README.md). 

### Clean up the unused data:

If you have upgraded to the latest stable release of v3 successfully, you can remove some unused data you may have in edge release.

Remove unnecessary data in mounted volume if you have:
    
```shell
rm -r public/uploads #All images assets already migrated  to Active Storage
rm -r storage_data/production_cache.sqlite3* # Previous used by litecache, already migrated to solid_cache 
rm -r storage_data/production_queue.sqlite3* # Previous used by litequeue, already migrated to solid_queue
```

Remove sidekiq and redis config if they are being used.

