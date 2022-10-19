class NativeBridge {
  playAll () {
    if (this._isTurboiOS) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playAll'
      })
    }
  }

  playSong (songId) {
    if (this._isTurboiOS) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playSong',
        songId: Number(songId)
      })
    }
  }

  search (query) {
    window.Turbo.visit(`/search?query=${query}`)
  }

  get nativeTitle () {
    return document.querySelector('meta[data-native-title]').dataset.nativeTitle
  }

  get isTurboNative () {
    return this._isTurboiOS
  }

  get _isTurboiOS () {
    return !!(window.webkit && window.webkit.messageHandlers)
  }
}

export default NativeBridge
