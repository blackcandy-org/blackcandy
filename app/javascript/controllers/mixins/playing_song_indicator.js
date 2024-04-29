export const installPlayingSongIndicator = (controller, getSongElements = () => {}) => {
  const showPlayingSong = () => {
    getSongElements().forEach((element) => {
      element.classList.toggle('is-active', Number(element.dataset.songId) === App.player.currentSong.id)
    })
  }

  const hidePlayingSong = () => {
    const playingSongElement = getSongElements().find((element) => element.classList.contains('is-active'))
    playingSongElement.classList.remove('is-active')
  }

  const addPlayingSongIndicatorEventListener = () => {
    document.addEventListener('songs:showPlaying', showPlayingSong)
    document.addEventListener('songs:hidePlaying', hidePlayingSong)
  }

  const removePlayingSongIndicatorEventListener = () => {
    document.removeEventListener('songs:showPlaying', showPlayingSong)
    document.removeEventListener('songs:hidePlaying', hidePlayingSong)
  }

  const controllerConnectCallback = controller.connect.bind(controller)
  const controllerDisconnectCallback = controller.disconnect.bind(controller)

  Object.assign(controller, {
    connect () {
      controllerConnectCallback()
      showPlayingSong()
      addPlayingSongIndicatorEventListener()
    },

    disconnect () {
      controllerDisconnectCallback()
      removePlayingSongIndicatorEventListener()
    }
  })
}
