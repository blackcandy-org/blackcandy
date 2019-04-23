import { Howl } from 'howler';
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
      song.howl = new Howl({
        src: [`/stream/new?song_id=${song.id}`],
        html5: true,
        onplay: this.onplay,
        onpause: this.onpause,
        onend: this.onend,
        onstop: this.onstop
      });
    }

    song.howl.play();
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

  seek(percent) {
    const sound = this.currentSong.howl;
    sound.seek(sound.duration() * percent);
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
    return this.playlist.map(song => song.id).indexOf(Number(songId));
  }
};

export default player;
