class NativeBridge {
  playAll () {
    if (this.#isTurboiOS) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playAll'
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
