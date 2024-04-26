import { isAndroidApp, isiOSApp } from './helper'

class NativeBridge {
  playResource (resourceType, resourceId) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playResource',
        resourceType,
        resourceId: Number(resourceId)
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.playResource(resourceType, Number(resourceId))
    }
  }

  playResourceBeginWith (resourceType, resourceId, songId) {
    if (isiOSApp()) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playResourceBeginWith',
        resourceType,
        resourceId: Number(resourceId),
        songId: Number(songId)
      })
    }

    if (isAndroidApp()) {
      window.NativeBridge.playResourceBeginWith(resourceType, Number(resourceId), Number(songId))
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
