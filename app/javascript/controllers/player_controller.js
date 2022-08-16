import { Controller } from '@hotwired/stimulus'
import { Howl } from 'howler'
import { formatDuration, dispatchEvent } from '../helper'

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
    this._initPlayer()
    this._initMode()
  }

  connect () {
    document.addEventListener('player:beforePlaying', this._setBeforePlayingStatus)
    document.addEventListener('player:playing', this._setPlayingStatus)
    document.addEventListener('player:pause', this._setPauseStatus)
    document.addEventListener('player:stop', this._setStopStatus)
    document.addEventListener('player:end', this._setEndStatus)
  }

  disconnect () {
    document.removeEventListener('player:beforePlaying', this._setBeforePlayingStatus)
    document.removeEventListener('player:playing', this._setPlayingStatus)
    document.removeEventListener('player:pause', this._setPauseStatus)
    document.removeEventListener('player:stop', this._setStopStatus)
    document.removeEventListener('player:end', this._setEndStatus)
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
    window.requestAnimationFrame(this._setProgress.bind(this))
  }

  collapse () {
    document.querySelector('#js-sidebar').classList.remove('is-expanded')
  }

  get player () {
    return window.App.player
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

  _setBeforePlayingStatus = () => {
    this.headerTarget.classList.add('is-expanded')
    this.loaderTarget.classList.remove('u-display-none')
    this.favoriteButtonTarget.classList.remove('u-visibility-hidden')
    this.songTimerTarget.textContent = formatDuration(0)
  }

  _setPlayingStatus = () => {
    const { currentSong } = this
    const favoriteSongUrl = new URL(this.favoriteButtonTarget.action)

    favoriteSongUrl.searchParams.set('song_id', currentSong.id)

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
    this.unFavoriteButtonTarget.action = favoriteSongUrl

    window.requestAnimationFrame(this._setProgress.bind(this))
    this.timerInterval = setInterval(this._setTimer.bind(this), 1000)

    // let playlist can show current palying song
    dispatchEvent(document, 'playlistSongs:showPlaying')
  }

  _setPauseStatus = () => {
    this._clearTimerInterval()

    this.pauseButtonTarget.classList.add('u-display-none')
    this.playButtonTarget.classList.remove('u-display-none')
  }

  _setStopStatus = () => {
    this._clearTimerInterval()

    if (this.player.playlist.length === 0) {
      this.headerTarget.classList.remove('is-expanded')
      this._setPauseStatus()
    }
  }

  _setEndStatus = () => {
    this._clearTimerInterval()

    if (this.currentMode === 'single') {
      this.player.play()
    } else {
      this.next()
    }
  }

  _setProgress () {
    this.progressTarget.value = (this.currentTime / this.currentSong.duration) * 100 || 0

    if (this.player.isPlaying) {
      window.requestAnimationFrame(this._setProgress.bind(this))
    }
  }

  _setTimer () {
    this.songTimerTarget.textContent = formatDuration(this.currentTime)
  }

  _clearTimerInterval () {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }
  }

  _initPlayer () {
    // Hack for Safari issue of can not play song when first time page loaded.
    // So call Howl init function manually let document have audio unlock event when click or touch.
    // When first time user interact page the audio will be unlocked.
    new Howl({ src: [''], format: ['mp3'] }) // eslint-disable-line no-new
  }

  _initMode () {
    this.modes = ['repeat', 'single', 'shuffle']
    this.currentModeIndex = 0
    this.updateMode()
  }
}
