class NativeBridge {
  playAll () {
    if (this._isiOSWebView) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        name: 'playAll'
      })
    }
  }

  search (query) {
    window.Turbo.visit(`/search?query=${query}`)
  }

  get nativeTitle () {
    return document.querySelector('meta[data-native-title]').dataset.nativeTitle
  }

  get _isiOSWebView () {
    return window.webkit && window.webkit.messageHandlers
  }
}

export default NativeBridge
