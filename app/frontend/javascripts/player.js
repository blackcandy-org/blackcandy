import { Howl } from 'howler';

function Player(playlist) {
  this.playlist = playlist;
  this.currentIndex = 0;
  this.currentSong = null;
}

async function fetchSong(id) {
  const response = await fetch(`songs/${id}`, { credentials: 'same-origin' });
  const songInfo = await response.json();

  return songInfo;
}

Player.prototype = {
  async play(currentIndex) {
    const song = this.playlist[currentIndex];

    if (!song.howl) {
      const data = await fetchSong(song.id);

      song.howl = new Howl({
        src: [data.url],
        html5: true,
      });

      Object.assign(song, data);
    }

    if (this.currentSong) {
      this.currentSong.howl.stop();
    }

    this.currentIndex = currentIndex;
    this.currentSong = song;

    song.howl.play();
  }
};

export default Player;
