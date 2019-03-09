import { Howl } from 'howler';
import { ajax } from 'rails-ujs';

const player = {
  playlist: null,
  currentIndex: 0,
  currentSong: {},
  onplay: null,
  onend: null,

  play(currentIndex) {
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
    this.stop();

    if (this.currentIndex + 1 >= this.playlist.length) {
      this.currentIndex = 0;
    } else {
      this.currentIndex += 1;
    }

    this.play(this.currentIndex);
  },

  previous() {
    this.stop();

    if (this.currentIndex - 1 < 0) {
      this.currentIndex = this.playlist.length - 1;
    } else {
      this.currentIndex -= 1;
    }

    this.play(this.currentIndex);
  },

  isPlaying() {
    return this.currentSong.howl && this.currentSong.howl.playing();
  },

  updatePlaylist(songIds) {
    this.playlist = songIds.map((songId) => {
      return { id: songId };
    });
  }
};

export default player;
