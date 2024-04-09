import { Howl, Howler } from 'howler'
import { dispatchEvent } from './helper'
import Playlist from './playlist'

class Player {
  currentSong = {}
  isPlaying = false
  playlist = new Playlist()

  playOn (index) {
    if (this.playlist.length === 0) { return }

    dispatchEvent(document, 'player:beforePlaying')

    const song = this.playlist.songs[index]
    this.currentSong = song
    this.isPlaying = true

    if (!song.howl) {
      song.howl = new Howl({
        src: [song.url],
        format: [song.format],
        html5: true,
        onplay: () => { dispatchEvent(document, 'player:playing') },
        onpause: () => { dispatchEvent(document, 'player:pause') },
        onend: () => { dispatchEvent(document, 'player:end') },
        onstop: () => { dispatchEvent(document, 'player:stop') }
      })
    }

    song.howl.play()
  }

  play () {
    this.isPlaying = true

    if (!this.currentSong.howl) {
      this.playOn(this.currentIndex)
    } else {
      this.currentSong.howl.play()
    }
  }

  pause () {
    this.isPlaying = false
    this.currentSong.howl && this.currentSong.howl.pause()
  }

  stop () {
    this.isPlaying = false

    Howler.stop()

    // reset current song
    this.currentSong = {}
  }

  next () {
    this.skipTo(this.currentIndex + 1)
  }

  previous () {
    this.skipTo(this.currentIndex - 1)
  }

  skipTo (index) {
    this.currentSong.howl && this.currentSong.howl.stop()

    if (index >= this.playlist.length) {
      index = 0
    } else if (index < 0) {
      index = this.playlist.length - 1
    }

    this.playOn(index)
  }

  seek (seconds) {
    this.currentSong.howl.seek(seconds)
  }

  get currentIndex () {
    return Math.max(this.playlist.indexOf(this.currentSong.id), 0)
  }
}

export default Player
