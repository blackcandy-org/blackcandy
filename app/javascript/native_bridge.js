class NativeBridge {
  playAll (resourceType, resourceId) {
    if (this.#isTurboiOS) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playAll',
        resourceType,
        resourceId: Number(resourceId)
      })
    }
  }

  playSong (songId) {
    if (this.#isTurboiOS) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playSong',
        songId: Number(songId)
      })
    }
  }

  playNext (songId) {
    if (this.#isTurboiOS) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playNext',
        songId: Number(songId)
      })
    }
  }

  playLast (songId) {
    if (this.#isTurboiOS) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playLast',
        songId: Number(songId)
      })
    }
  }

  search (query) {
    window.Turbo.visit(`/search?query=${query}`)
  }

  updateTheme (theme) {
    if (this.#isTurboiOS) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'updateTheme',
        theme
      })
    }
  }

  get isTurboNative () {
    return this.#isTurboiOS
  }

  get #isTurboiOS () {
    return !!(window.webkit && window.webkit.messageHandlers)
  }
}

export default NativeBridge
