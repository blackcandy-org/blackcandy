import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['songName', 'playButton', 'pauseButton', 'loader']

  initialize () {
    this.#initPlayer()
  }

  connect () {
    document.addEventListener('player:beforePlaying', this.#setBeforePlayingStatus)
    document.addEventListener('player:playing', this.#setPlayingStatus)
    document.addEventListener('player:pause', this.#setPauseStatus)
  }

  disconnect () {
    document.removeEventListener('player:beforePlaying', this.#setBeforePlayingStatus)
    document.removeEventListener('player:playing', this.#setPlayingStatus)
    document.removeEventListener('player:pause', this.#setPauseStatus)
  }

  play () {
    this.player.play()
  }

  pause () {
    this.player.pause()
  }

  next () {
    this.player.next()
  }

  expand () {
    document.querySelector('#js-sidebar').classList.add('is-expanded')
  }

  #setBeforePlayingStatus = () => {
    this.loaderTarget.classList.remove('u-display-none')
    this.songNameTarget.classList.add('u-display-none')
  }

  #setPlayingStatus = () => {
    this.songNameTarget.textContent = this.player.currentSong.name
    this.loaderTarget.classList.add('u-display-none')
    this.songNameTarget.classList.remove('u-display-none')
    this.pauseButtonTarget.classList.remove('u-display-none')
    this.playButtonTarget.classList.add('u-display-none')
  }

  #setPauseStatus = () => {
    this.pauseButtonTarget.classList.add('u-display-none')
    this.playButtonTarget.classList.remove('u-display-none')
  }

  #initPlayer () {
    this.player = App.player
  }

  get currentIndex () {
    return this.player.currentIndex
  }
}
