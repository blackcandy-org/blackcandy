export const installPlayingSongIndicator = (controller, getSongElements = () => {}) => {
  const showPlayingSong = () => {
    getSongElements().forEach((element) => {
      const isCurrent = Number(element.dataset.songId) === App.player.currentSong.id
      element.classList.toggle('is-active', isCurrent)

      if (isCurrent) { element.classList.remove('is-paused') }
    })
  }

  const hidePlayingSong = () => {
    const playingSongElement = getSongElements().find((element) => element.classList.contains('is-active'))
    playingSongElement.classList.remove('is-active', 'is-paused')
  }

  const pausePlayingSong = () => {
    const playingSongElement = getSongElements().find((element) => element.classList.contains('is-active'))
    playingSongElement?.classList.add('is-paused')
  }

  const addPlayingSongIndicatorEventListener = () => {
    document.addEventListener('songs:showPlaying', showPlayingSong)
    document.addEventListener('songs:hidePlaying', hidePlayingSong)
    document.addEventListener('songs:pausePlaying', pausePlayingSong)
  }

  const removePlayingSongIndicatorEventListener = () => {
    document.removeEventListener('songs:showPlaying', showPlayingSong)
    document.removeEventListener('songs:hidePlaying', hidePlayingSong)
    document.removeEventListener('songs:pausePlaying', pausePlayingSong)
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
