import { isAndroidApp, isiOSApp } from './helper'

class NativeBridge {
  playAll (resourceType, resourceId) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playAll',
        resourceType,
        resourceId: Number(resourceId)
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.playAll(resourceType, Number(resourceId))
    }
  }

  playSong (songId) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playSong',
        songId: Number(songId)
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.playSong(Number(songId))
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
