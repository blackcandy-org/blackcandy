import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'

export default class extends Controller {
  static targets = ['songName', 'playButton', 'pauseButton', 'loader']

  initialize () {
    this.#initPlayer()
    installEventHandler(this)
  }

  connect () {
    this.handleEvent('player:beforePlaying', { with: this.#setBeforePlayingStatus })
    this.handleEvent('player:playing', { with: this.#setPlayingStatus })
    this.handleEvent('player:pause', { with: this.#setPauseStatus })
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
