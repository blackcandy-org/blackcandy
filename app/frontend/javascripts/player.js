import { Howl } from 'howler';
import { ajax } from 'rails-ujs';

const player = {
  playlist: [],
  currentIndex: 0,
  currentSong: {},
  onplay: () => {},

  play(currentIndex) {
    const song = {
      id: this.playlist[currentIndex]
    };

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
          });

          Object.assign(song, response);

          this.currentIndex = currentIndex;
          this.currentSong = song;

          song.howl.play();
        }
      });
    }
  },

  pause() {
    this.currentSong.howl.pause();
  },

  next() {
    if (this.currentIndex + 1 >= this.playlist.length) {
      this.currentIndex = 0;
    } else {
      this.currentIndex += 1;
    }

    this.currentSong.howl.stop();
    this.play(this.currentIndex);
  },

  previous() {
    if (this.currentIndex - 1 < 0) {
      this.currentIndex = this.playlist.length - 1;
    } else {
      this.currentIndex -= 1;
    }

    this.currentSong.howl.stop();
    this.play(this.currentIndex);
  },

  isPlaying() {
    return this.currentSong.howl ? this.currentSong.howl.playing() : false;
  }
};

export default player;
