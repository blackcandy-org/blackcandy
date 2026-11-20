import { Howl, Howler } from 'howler'
import { dispatchEvent } from './helper'

class Player {
  onplay = () => {}
  onend = () => {}
  #howl = null
  #songId

  constructor () {
    // Hack for Safari issue of can not play song when first time page loaded.
    // So call Howl init function manually let document have audio unlock event when click or touch.
    // When first time user interact page the audio will be unlocked.
    new Howl({ src: [''], format: ['mp3'] }) // eslint-disable-line no-new
  }

  load (song) {
    dispatchEvent(document, 'player:beforePlaying')

    if (this.#songId === song.id) {
      this.#howl.stop()
      return
    }

    this.#unload()
    this.#songId = song.id
    this.#howl = new Howl({
      src: [song.url],
      format: [song.format],
      html5: true,
      volume: 1.0,
      onplay: () => {
        dispatchEvent(document, 'player:playing')
        this.onplay()
      },
      onpause: () => { dispatchEvent(document, 'player:pause') },
      onend: () => {
        dispatchEvent(document, 'player:end')
        this.onend()
      },
      onstop: () => { dispatchEvent(document, 'player:stop') },
      onseek: () => { dispatchEvent(document, 'player:seek') }
    })
  }

  play () {
    this.#howl && this.#howl.play()
  }

  pause () {
    this.#howl && this.#howl.pause()
  }

  stop () {
    Howler.stop()
    this.#unload()
  }

  seek (seconds) {
    if (!this.#howl) { return }

    this.#howl.seek(seconds)
  }

  setVolume (value) {
    Howler.volume(value)
  }

  get currentTime () {
    const currentTime = this.#howl ? this.#howl.seek() : 0
    return (typeof currentTime === 'number') ? currentTime : 0
  }

  #unload () {
    if (!this.#howl) { return }

    this.#howl.unload()
    this.#howl = null
    this.#songId = undefined
  }
}

export default Player
