import { randomIndex, shuffle } from './helper'

class Playlist {
  orderedSongs = []
  shuffledSongs = []
  isShuffled = false

  update (songIds) {
    this.orderedSongs = songIds.map((songId) => {
      return { id: Number(songId) }
    })

    this.shuffledSongs = shuffle(Object.assign([], this.songs))
  }

  pushSong (songId, toTheLast = false) {
    const song = { id: Number(songId) }
    let pushIndex = this.#indexOfSongs(this.orderedSongs, App.player.currentSong.id) + 1

    if (toTheLast) {
      pushIndex = this.length
    }

    this.orderedSongs.splice(pushIndex, 0, song)
    this.shuffledSongs.splice(randomIndex(this.shuffledSongs.length), 0, song)

    return this.indexOf(songId)
  }

  deleteSong (songId) {
    const orderedSongsindex = this.#indexOfSongs(this.orderedSongs, songId)
    const shuffledSongsindex = this.#indexOfSongs(this.shuffledSongs, songId)

    this.orderedSongs.splice(orderedSongsindex, 1)
    this.shuffledSongs.splice(shuffledSongsindex, 1)

    return this.isShuffled ? shuffledSongsindex : orderedSongsindex
  }

  indexOf (songId) {
    return this.#indexOfSongs(this.songs, songId)
  }

  move (fromIndex, toIndex) {
    this.orderedSongs.splice(toIndex, 0, this.orderedSongs.splice(fromIndex, 1)[0])
  }

  #indexOfSongs (songs, songId) {
    return songs.map((song) => song.id).indexOf(Number(songId))
  }

  get songs () {
    return this.isShuffled ? this.shuffledSongs : this.orderedSongs
  }

  get length () {
    return this.songs.length
  }
}

export default Playlist
