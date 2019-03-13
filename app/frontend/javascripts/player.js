import { Howl } from 'howler';
import { ajax } from 'rails-ujs';
import { shuffle } from './helper';

const player = {
  currentIndex: 0,
  currentSong: {},
  isShuffle: false,

  play(currentIndex) {
    if (this.playlist.length == 0) { return; }

    const song = this.playlist[currentIndex];
    this.currentIndex = currentIndex;
    this.currentSong = song;

    if (!song.howl) {
      ajax({
        url: `/songs/${song.id}`,
        type: 'get',
        dataType: 'json',
        success: (response) => {
          song.howl = new Howl({
            src: [response.url],
            html5: true,
            onplay: this.onplay,
            onpause: this.onpause,
            onend: this.onend
          });

          Object.assign(song, response);
          song.howl.play();
        }
      });
    } else {
      song.howl.play();
    }
  },

  pause() {
    this.currentSong.howl && this.currentSong.howl.pause();
  },

  stop() {
    this.currentSong.howl && this.currentSong.howl.stop();
  },

  next() {
    this.skipTo(this.currentIndex + 1);
  },

  previous() {
    this.skipTo(this.currentIndex - 1);
  },

  skipTo(index) {
    this.stop();

    if (index >= this.playlist.length) {
      index = 0;
    } else if (index < 0) {
      index = this.playlist.length - 1;
    }

    this.play(index);
  },

  isPlaying() {
    return this.currentSong.howl && this.currentSong.howl.playing();
  },

  updateShuffleStatus(isShuffle) {
    this.isShuffle = isShuffle;
    this.playlist = isShuffle ?
      shuffle(Object.assign([], this.normalPlaylist)) :
      this.normalPlaylist;
  },

  updatePlaylist(songIds) {
    this.normalPlaylist = songIds.map((songId) => {
      return { id: Number(songId) };
    });

    this.playlist = this.normalPlaylist;
  },

  pushToPlaylist(songId) {
    const song = { id: Number(songId) };

    this.normalPlaylist.push(song);
    this.updateShuffleStatus(this.isShuffle);

    return this.playlist.indexOf(song); // return index of new song
  },

  playlistIndexOf(songId) {
    return this.playlist.map(song => song.id).indexOf(Number(songId));
  }
};

export default player;
