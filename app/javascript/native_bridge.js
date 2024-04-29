import { isAndroidApp, isiOSApp } from './helper'

class NativeBridge {
  playAlbum (albumId) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playAlbum',
        albumId: Number(albumId)
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.playAlbum(Number(albumId))
    }
  }

  playAlbumBeginWith (albumId, songId) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playAlbumBeginWith',
        albumId: Number(albumId),
        songId: Number(songId)
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.playAlbumBeginWith(Number(albumId), Number(songId))
    }
  }

  playPlaylist (playlistId) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playPlaylist',
        playlistId: Number(playlistId)
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.playPlaylist(Number(playlistId))
    }
  }

  playPlaylistBeginWith (playlistId, songId) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playPlaylistBeginWith',
        playlistId: Number(playlistId),
        songId: Number(songId)
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.playPlaylistBeginWith(Number(playlistId), Number(songId))
    }
  }

  playNow (songId) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playNow',
        songId: Number(songId)
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.playNow(Number(songId))
    }
  }

  playNext (songId) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playNext',
        songId: Number(songId)
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.playNext(Number(songId))
    }
  }

  playLast (songId) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playLast',
        songId: Number(songId)
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.playLast(Number(songId))
    }
  }

  search (query) {
    window.Turbo.visit(`/search?query=${query}`)
  }

  updateTheme (theme) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'updateTheme',
        theme
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.updateTheme(theme)
    }
  }

  showFlashMessage (message) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'showFlashMessage',
        message
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.showFlashMessage(message)
    }
  }
}

export default NativeBridge
