import { Howl } from 'howler';
import { ajax } from '@rails/ujs';
import { shuffle } from './helper';

const player = {
  currentIndex: 0,
  currentSong: {},
  currentPlaylistId: null,
  favoritePlaylistId: null,
  selectedSongId: null,
  isShuffle: false,
  isPlaying: false,

  play(currentIndex) {
    if (this.playlist.length == 0) { return; }

    App.dispatchEvent(document, 'player:beforePlaying');

    const song = this.playlist[currentIndex];
    this.currentIndex = currentIndex;
    this.currentSong = song;
    this.isPlaying = true;

    if (!song.howl) {
      ajax({
        url: `/songs/${song.id}`,
        type: 'get',
        dataType: 'json',
        success: (response) => {
          song.howl = new Howl({
            src: [response.url],
            format: [response.format],
            html5: true,
            onplay: () => { App.dispatchEvent(document, 'player:playing'); },
            onpause: () => { App.dispatchEvent(document, 'player:pause'); },
            onend: () => { App.dispatchEvent(document, 'player:end'); },
            onstop: () => { App.dispatchEvent(document, 'player:stop'); }
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
    this.isPlaying = false;
    this.currentSong.howl && this.currentSong.howl.pause();
  },

  stop() {
    this.isPlaying = false;
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

  seek(percent) {
    this.currentSong.howl.seek(this.currentSong.length * percent);
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

    this.updateShuffleStatus(this.isShuffle);
  },

  pushToPlaylist(songId) {
    const song = { id: Number(songId) };

    this.normalPlaylist.push(song);
    this.updateShuffleStatus(this.isShuffle);

    return this.playlist.indexOf(song); // return index of new song
  },

  deleteFromPlaylist(songId) {
    const index = this.playlistIndexOf(songId);

    this.normalPlaylist.splice(index, 1);
    this.updateShuffleStatus(this.isShuffle);

    if (this.currentSong.id == Number(songId)) { this.skipTo(index); }
  },

  playlistIndexOf(songId) {
    return this.playlist.map((song) => song.id).indexOf(Number(songId));
  }
};

export default player;
