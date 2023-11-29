export const installPlayingSongIndicator = (controller, getSongElements = () => {}) => {
  const showPlayingSong = () => {
    getSongElements().forEach((element) => {
      element.classList.toggle('is-active', Number(element.dataset.songId) === App.player.currentSong.id)
    })
  }

  const addShowPlayingEventListener = () => {
    document.addEventListener('playlistSongs:showPlaying', showPlayingSong)
  }

  const removeShowPlayingEventListener = () => {
    document.removeEventListener('playlistSongs:showPlaying', showPlayingSong)
  }

  const controllerConnectCallback = controller.connect.bind(controller)
  const controllerDisconnectCallback = controller.disconnect.bind(controller)

  Object.assign(controller, {
    connect () {
      controllerConnectCallback()
      showPlayingSong()
      addShowPlayingEventListener()
    },

    disconnect () {
      controllerDisconnectCallback()
      removeShowPlayingEventListener()
    }
  })
}
