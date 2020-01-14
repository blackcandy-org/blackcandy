import { randomIndex, shuffle } from './helper';

class Playlist {
  orderedSongs = [];
  shuffledSongs = [];
  isShuffled = false;

  update(songIds) {
    this.orderedSongs = songIds.map((songId) => {
      return { id: Number(songId) };
    });

    this.shuffledSongs = shuffle(Object.assign([], this.songs));
  }


  pushSong(songId) {
    const song = { id: Number(songId) };

    this.orderedSongs.push(song);
    this.shuffledSongs.splice(randomIndex(this.shuffledSongs.length), 0, song);

    return this.indexOf(songId);
  }

  deleteSong(songId) {
    const orderedSongsindex = this._indexOfSongs(this.orderedSongs, songId);
    const shuffledSongsindex = this._indexOfSongs(this.shuffledSongs, songId);

    this.orderedSongs.splice(orderedSongsindex, 1);
    this.shuffledSongs.splice(shuffledSongsindex, 1);

    return this.isShuffled ? shuffledSongsindex : orderedSongsindex;
  }

  indexOf(songId) {
    return this._indexOfSongs(this.songs, songId);
  }

  _indexOfSongs(songs, songId) {
    return songs.map((song) => song.id).indexOf(Number(songId));
  }

  get songs() {
    return this.isShuffled ? this.shuffledSongs : this.orderedSongs;
  }

  get length() {
    return this.songs.length;
  }
}

export default Playlist;
