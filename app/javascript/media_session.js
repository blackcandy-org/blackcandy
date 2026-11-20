const DEFAULT_SKIP_TIME = 10

export default function setUpMediaSession (store) {
  if (!('mediaSession' in navigator)) { return }

  document.addEventListener('player:playing', () => {
    updateMetadata(store)
    updatePositionState(store)
  })

  Object.entries(mediaSessionActions(store)).forEach(([actionName, actionHandler]) => {
    try {
      navigator.mediaSession.setActionHandler(actionName, actionHandler)
    } catch (error) {
      // The media session ation is not supported.
    }
  })
}

function mediaSessionActions (store) {
  return {
    play: () => store.play(),
    pause: () => store.pause(),
    previoustrack: () => store.previous(),
    nexttrack: () => store.next(),
    stop: () => store.stop(),

    seekbackward: (event) => {
      const skipTime = event.seekOffset || DEFAULT_SKIP_TIME

      store.seek(store.currentTime - skipTime)
      updatePositionState(store)
    },

    seekforward: (event) => {
      const skipTime = event.seekOffset || DEFAULT_SKIP_TIME

      store.seek(store.currentTime + skipTime)
      updatePositionState(store)
    },

    seekto: (event) => {
      store.seek(event.seekTime)
      updatePositionState(store)
    }
  }
}

function updateMetadata (store) {
  const { currentSong } = store

  navigator.mediaSession.metadata = new MediaMetadata({
    title: currentSong.name,
    artist: currentSong.artist_name,
    album: currentSong.album_name,
    artwork: [
      { src: currentSong.album_image_urls.small, sizes: '200x200' },
      { src: currentSong.album_image_urls.medium, sizes: '300x300' },
      { src: currentSong.album_image_urls.large, sizes: '400x400' }
    ]
  })
}

function updatePositionState (store) {
  if (!('setPositionState' in navigator.mediaSession)) { return }

  navigator.mediaSession.setPositionState({
    duration: store.currentSong.duration,
    position: store.currentTime
  })
}
