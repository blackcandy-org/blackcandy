import { Howl, Howler } from 'howler';

function Player(playlist) {
  this.playlist = playlist;
  this.currentIndex = 0;
  this.currentSong = {};
  this.onplay = () => {};
  this.onpause = () => {};
}

async function fetchSong(id) {
  const response = await fetch(`songs/${id}`, { credentials: 'same-origin' });
  const songInfo = await response.json();

  return songInfo;
}

Player.prototype = {
  async play(currentIndex) {
    const song = {
      id: this.playlist[currentIndex]
    };

    if (!song.howl) {
      const data = await fetchSong(song.id);

      song.howl = new Howl({
        src: [data.url],
        html5: true,
        onplay: this.onplay,
        onpause: this.onpause
      });

      Object.assign(song, data);
    }

    if (this.currentSong.howl && song !== this.currentSong) {
      this.currentSong.howl.stop();
    }

    this.currentIndex = currentIndex;
    this.currentSong = song;

    song.howl.play();
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

    this.play(this.currentIndex);
  },

  previous() {
    if (this.currentIndex - 1 < 0) {
      this.currentIndex = this.playlist.length - 1;
    } else {
      this.currentIndex -= 1;
    }

    this.play(this.currentIndex);
  },

  isPlaying() {
    return this.currentSong.howl ? this.currentSong.howl.playing() : false;
  },

  volume(value) {
    localStorage.setItem('volume', value);
    Howler.volume(value);
  }
};

export default Player;
