import { randomIndex } from './helper'

class Playlist {
  orderedSongs = []
  shuffledSongs = []
  isShuffled = false

  insert (index, song) {
    if (this.includes(song.id)) { return }

    this.orderedSongs.splice(index, 0, song)
    this.shuffledSongs.splice(randomIndex(this.shuffledSongs.length), 0, song)
  }

  deleteSong (songId) {
    if (!this.includes(songId)) { return -1 }

    const orderedSongsindex = this.#indexOfSongs(this.orderedSongs, songId)
    const shuffledSongsindex = this.#indexOfSongs(this.shuffledSongs, songId)

    this.orderedSongs.splice(orderedSongsindex, 1)
    this.shuffledSongs.splice(shuffledSongsindex, 1)

    return this.isShuffled ? shuffledSongsindex : orderedSongsindex
  }

  indexOf (songId) {
    return this.#indexOfSongs(this.songs, songId)
  }

  includes (songId) {
    return this.indexOf(songId) !== -1
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
