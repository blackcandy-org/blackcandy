import consumer from './consumer'

consumer.subscriptions.create('ThemeChannel', {
  received (data) {
    const theme = data.theme

    document.body.dataset.colorScheme = theme
    App.nativeBridge.updateTheme(theme)
  }
})
