### 1.0.4

- enhancements
  - add ssl setup use lets encrypt 

### 1.0.3

- bug fixes
  - keep pid directory on tmp to avoid puma loading error

### 1.0.2

- new features
  - add light theme support
  - fix issue #12, add opus support

- bug fixes
  - fix missing partial error when clear playlist
  - fix theme issue when user did not login
  - fix error when get image from m4a file
  - fix issue #8, use mtime and file_path to get md5hash rather than file content
  - fix style issue on radio input
  - fix issue of normal user can not see page of settings
  - fix issue of show empty image tag behind player loader when playing first song

- enhancements
  - fix server.pid issue on dev
  - update Rails to 6.0
  - fix SQL injection on serach
  - fix N+1 issues on albums ans songs page
  - use carrierwave to replace active storage
