import { Howl } from 'howler'
import { fetchRequest, dispatchEvent } from './helper'
import Playlist from './playlist'
import Cookies from 'js-cookie'

class Player {
  currentIndex = 0
  currentSong = {}
  isPlaying = false
  playlist = new Playlist()

  constructor () {
    // Remove current song id from cookies if there is no current playing song
    Cookies.remove('current_song_id')
  }

  playOn (index) {
    if (this.playlist.length === 0) { return }

    dispatchEvent(document, 'player:beforePlaying')

    const song = this.playlist.songs[index]
    this.currentIndex = index
    this.currentSong = song
    this.isPlaying = true

    if (!song.howl) {
      fetchRequest(`/api/v1/songs/${song.id}`)
        .then((response) => {
          return response.json()
        })
        .then((data) => {
          song.howl = new Howl({
            src: [data.url],
            format: [data.format],
            html5: true,
            onplay: () => { dispatchEvent(document, 'player:playing') },
            onpause: () => { dispatchEvent(document, 'player:pause') },
            onend: () => { dispatchEvent(document, 'player:end') },
            onstop: () => { dispatchEvent(document, 'player:stop') }
          })

          Object.assign(song, data)
          song.howl.play()
        })
    } else {
      song.howl.play()
    }

    // keep track id of the current playing song
    Cookies.set('current_song_id', song.id)
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
    this.currentSong.howl && this.currentSong.howl.stop()

    if (this.playlist.length === 0) {
      // reset current song
      this.currentIndex = 0
      this.currentSong = {}
    }
  }

  next () {
    this.skipTo(this.currentIndex + 1)
  }

  previous () {
    this.skipTo(this.currentIndex - 1)
  }

  skipTo (index) {
    this.stop()

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
}

export default Player
