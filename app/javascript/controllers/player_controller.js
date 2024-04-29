import { Controller } from '@hotwired/stimulus'
import { Howl } from 'howler'
import { formatDuration, dispatchEvent } from '../helper'
import { installEventHandler } from './mixins/event_handler'

export default class extends Controller {
  static targets = [
    'header',
    'image',
    'backgroundImage',
    'songName',
    'artistName',
    'albumName',
    'songDuration',
    'songTimer',
    'progress',
    'playButton',
    'pauseButton',
    'favoriteButton',
    'unFavoriteButton',
    'modeButton',
    'loader'
  ]

  initialize () {
    this.#initPlayer()
    this.#initMode()

    installEventHandler(this)
  }

  connect () {
    this.handleEvent('player:beforePlaying', { with: this.#setBeforePlayingStatus })
    this.handleEvent('player:playing', { with: this.#setPlayingStatus })
    this.handleEvent('player:pause', { with: this.#setPauseStatus })
    this.handleEvent('player:stop', { with: this.#setStopStatus })
    this.handleEvent('player:end', { with: this.#setEndStatus })
  }

  play () {
    this.player.play()
  }

  pause () {
    this.player.pause()
  }

  toggleFavorite (event) {
    if (!event.detail.success) { return }

    const isFavorited = this.currentSong.is_favorited

    this.currentSong.is_favorited = !isFavorited
    this.favoriteButtonTarget.classList.toggle('u-display-none', !isFavorited)
    this.unFavoriteButtonTarget.classList.toggle('u-display-none', isFavorited)
  }

  nextMode () {
    if (this.currentModeIndex + 1 >= this.modes.length) {
      this.currentModeIndex = 0
    } else {
      this.currentModeIndex += 1
    }

    this.updateMode()
  }

  updateMode () {
    this.modeButtonTargets.forEach((element) => {
      element.classList.toggle('u-display-none', element !== this.modeButtonTargets[this.currentModeIndex])
    })

    this.player.playlist.isShuffled = (this.currentMode === 'shuffle')
  }

  next () {
    this.player.next()
  }

  previous () {
    this.player.previous()
  }

  seek (event) {
    this.player.seek((event.offsetX / event.target.offsetWidth) * this.currentSong.duration)
    window.requestAnimationFrame(this.#setProgress.bind(this))
  }

  collapse () {
    document.querySelector('#js-sidebar').classList.remove('is-expanded')
  }

  get player () {
    return App.player
  }

  get currentIndex () {
    return this.player.currentIndex
  }

  get currentSong () {
    return this.player.currentSong
  }

  get currentMode () {
    return this.modes[this.currentModeIndex]
  }

  get currentTime () {
    const currentTime = this.currentSong.howl ? this.currentSong.howl.seek() : 0
    return (typeof currentTime === 'number') ? Math.round(currentTime) : 0
  }

  get isEndOfPlaylist () {
    return this.currentIndex === this.player.playlist.length - 1
  }

  #setBeforePlayingStatus = () => {
    this.headerTarget.classList.add('is-expanded')
    this.loaderTarget.classList.remove('u-display-none')
    this.favoriteButtonTarget.classList.remove('u-visibility-hidden')
    this.songTimerTarget.textContent = formatDuration(0)
  }

  #setPlayingStatus = () => {
    const { currentSong } = this
    const favoriteSongUrl = `/favorite_playlist/songs?song_id=${currentSong.id}`
    const unFavoriteSongUrl = `/favorite_playlist/songs/${currentSong.id}`

    this.imageTarget.src = currentSong.album_image_url.small
    this.backgroundImageTarget.style.backgroundImage = `url(${currentSong.album_image_url.small})`
    this.songNameTarget.textContent = currentSong.name
    this.artistNameTarget.textContent = currentSong.artist_name
    this.albumNameTarget.textContent = currentSong.album_name
    this.songDurationTarget.textContent = formatDuration(currentSong.duration)

    this.pauseButtonTarget.classList.remove('u-display-none')
    this.playButtonTarget.classList.add('u-display-none')
    this.loaderTarget.classList.add('u-display-none')

    this.favoriteButtonTarget.classList.toggle('u-display-none', currentSong.is_favorited)
    this.unFavoriteButtonTarget.classList.toggle('u-display-none', !currentSong.is_favorited)
    this.favoriteButtonTarget.action = favoriteSongUrl
    this.unFavoriteButtonTarget.action = unFavoriteSongUrl

    window.requestAnimationFrame(this.#setProgress.bind(this))
    this.timerInterval = setInterval(this.#setTimer.bind(this), 1000)

    // let playlist can show current playing song
    dispatchEvent(document, 'songs:showPlaying')
  }

  #setPauseStatus = () => {
    this.#clearTimerInterval()

    this.pauseButtonTarget.classList.add('u-display-none')
    this.playButtonTarget.classList.remove('u-display-none')
  }

  #setStopStatus = () => {
    this.#setPauseStatus()

    if (!this.currentSong.id) {
      this.headerTarget.classList.remove('is-expanded')
      dispatchEvent(document, 'songs:hidePlaying')
    }
  }

  #setEndStatus = () => {
    this.#clearTimerInterval()

    switch (this.currentMode) {
      case 'noRepeat':
        if (this.isEndOfPlaylist) {
          this.player.stop()
        } else {
          this.next()
        }
        break
      case 'single':
        this.player.play()
        break
      default:
        this.next()
    }
  }

  #setProgress () {
    this.progressTarget.value = (this.currentTime / this.currentSong.duration) * 100 || 0

    if (this.player.isPlaying) {
      window.requestAnimationFrame(this.#setProgress.bind(this))
    }
  }

  #setTimer () {
    this.songTimerTarget.textContent = formatDuration(this.currentTime)
  }

  #clearTimerInterval () {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }
  }

  #initPlayer () {
    // Hack for Safari issue of can not play song when first time page loaded.
    // So call Howl init function manually let document have audio unlock event when click or touch.
    // When first time user interact page the audio will be unlocked.
    new Howl({ src: [''], format: ['mp3'] }) // eslint-disable-line no-new
  }

  #initMode () {
    this.modes = ['noRepeat', 'repeat', 'single', 'shuffle']
    this.currentModeIndex = 0
    this.updateMode()
  }
}
