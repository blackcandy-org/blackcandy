import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'

export default class extends Controller {
  DEFAULT_SKIP_TIME = 10

  initialize () {
    installEventHandler(this)
  }

  connect () {
    if (!('mediaSession' in navigator)) { return }

    this.handleEvent('player:playing', { with: this.#setPlayingStatus })

    Object.entries(this.mediaSessionActions).forEach(([actionName, actionHandler]) => {
      try {
        navigator.mediaSession.setActionHandler(actionName, actionHandler)
      } catch (error) {
        // The media session ation is not supported.
      }
    })
  }

  #setPlayingStatus = () => {
    this.#updateMetadata()
    this.#updatePositionState()
  }

  #updateMetadata = () => {
    navigator.mediaSession.metadata = new MediaMetadata({
      title: this.currentSong.name,
      artist: this.currentSong.artist_name,
      album: this.currentSong.album_name,
      artwork: [
        { src: this.currentSong.album_image_url.small, sizes: '200x200' },
        { src: this.currentSong.album_image_url.medium, sizes: '300x300' },
        { src: this.currentSong.album_image_url.large, sizes: '400x400' }
      ]
    })
  }

  #updatePositionState = () => {
    if (!('setPositionState' in navigator.mediaSession)) { return }

    navigator.mediaSession.setPositionState({
      duration: this.currentSong.duration,
      playbackRate: this.currentSong.howl.rate(),
      position: this.currentSong.howl.seek()
    })
  }

  #play = () => {
    this.player.play()
  }

  #pause = () => {
    this.player.pause()
  }

  #next = () => {
    this.player.next()
  }

  #previous = () => {
    this.player.previous()
  }

  #stop = () => {
    this.player.stop()
  }

  #seekBackward = (event) => {
    const skipTime = event.seekOffset || this.DEFAULT_SKIP_TIME

    this.player.seek(this.currentSong.howl.seek() - skipTime)
    this.#updatePositionState()
  }

  #seekForward = (event) => {
    const skipTime = event.seekOffset || this.DEFAULT_SKIP_TIME

    this.player.seek(this.currentSong.howl.seek() + skipTime)
    this.#updatePositionState()
  }

  #seekTo = (event) => {
    this.player.seek(event.seekTime)
    this.#updatePositionState()
  }

  get mediaSessionActions () {
    return {
      play: this.#play,
      pause: this.#pause,
      previoustrack: this.#previous,
      nexttrack: this.#next,
      stop: this.#stop,
      seekbackward: this.#seekBackward,
      seekforward: this.#seekForward,
      seekto: this.#seekTo
    }
  }

  get player () {
    return App.player
  }

  get currentSong () {
    return this.player.currentSong
  }

  get currentIndex () {
    return this.player.currentIndex
  }
}
