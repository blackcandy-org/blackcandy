import Player from '../player'
import Playlist from '../playlist'
import setUpMediaSession from '../media_session'

const MODES = ['noRepeat', 'repeat', 'single', 'shuffle']

const player = new Player()
const playlist = new Playlist()

export default {
  currentSong: {},
  isPlaying: false,
  isLoading: false,
  mode: MODES[0],
  volume: 1,

  init () {
    player.onplay = () => {
      this.isLoading = false
    }

    player.onend = () => {
      songEnded(this)
    }

    this.setVolume(window.localStorage.getItem('playerVolume') || 1)
    setUpMediaSession(this)
  },

  play () {
    if (!this.hasCurrentSong) {
      playOn(this, this.currentIndex)
      return
    }

    this.isPlaying = true
    player.play()
  },

  pause () {
    this.isPlaying = false
    player.pause()
  },

  stop () {
    this.isPlaying = false
    player.stop()
    this.currentSong = {}
  },

  next () {
    this.skipTo(this.currentIndex + 1)
  },

  previous () {
    this.skipTo(this.currentIndex - 1)
  },

  skipTo (index) {
    if (index >= playlist.length) {
      index = 0
    } else if (index < 0) {
      index = playlist.length - 1
    }

    playOn(this, index)
  },

  seek (seconds) {
    player.seek(seconds)
  },

  setVolume (value) {
    this.volume = value
    player.setVolume(value)
    window.localStorage.setItem('playerVolume', value)
  },

  nextMode () {
    this.mode = MODES[(MODES.indexOf(this.mode) + 1) % MODES.length]
    playlist.isShuffled = (this.mode === 'shuffle')
  },

  insertSong (index, song) {
    playlist.insert(index, song)
  },

  deleteSong (songId) {
    playlist.deleteSong(songId)
  },

  indexOf (songId) {
    return playlist.indexOf(songId)
  },

  setFavorited (songId, isFavorited) {
    if (this.currentSong.id !== songId) { return }

    this.currentSong.is_favorited = isFavorited
  },

  get currentIndex () {
    return Math.max(playlist.indexOf(this.currentSong.id), 0)
  },

  get currentTime () {
    return player.currentTime
  },

  get hasCurrentSong () {
    return this.currentSong.id !== undefined
  }
}

function playOn (store, index) {
  if (playlist.length === 0) { return }

  const song = playlist.songs[index]

  Object.assign(store, { currentSong: song, isPlaying: true, isLoading: true })
  player.load(song)
  player.play()
}

function songEnded (store) {
  const isEndOfPlaylist = store.currentIndex === playlist.length - 1

  switch (store.mode) {
    case 'noRepeat':
      if (isEndOfPlaylist) {
        store.stop()
      } else {
        store.next()
      }
      break
    case 'single':
      store.play()
      break
    default:
      store.next()
  }
}
