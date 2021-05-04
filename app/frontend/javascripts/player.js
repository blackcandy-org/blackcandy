import { Howl } from 'howler';
import { fetchRequest, dispatchEvent } from './helper';
import Playlist from './playlist';

class Player {
  urrentIndex = 0;
  currentSong = {};
  isPlaying = false;
  playlist = new Playlist();

  play(currentIndex) {
    if (this.playlist.length == 0) { return; }

    dispatchEvent(document, 'player:beforePlaying');

    const song = this.playlist.songs[currentIndex];
    this.currentIndex = currentIndex;
    this.currentSong = song;
    this.isPlaying = true;

    if (!song.howl) {
      fetchRequest(`/songs/${song.id}`)
        .then((response) => {
          return response.json();
        })
        .then((data) => {
          song.howl = new Howl({
            src: [data.url],
            format: [data.format],
            html5: true,
            onplay: () => { dispatchEvent(document, 'player:playing'); },
            onpause: () => { dispatchEvent(document, 'player:pause'); },
            onend: () => { dispatchEvent(document, 'player:end'); },
            onstop: () => { dispatchEvent(document, 'player:stop'); }
          });

          Object.assign(song, data);
          song.howl.play();
        });
    } else {
      song.howl.play();
    }

    // keep track id of the current playing song
    document.cookie = `current_song_id=${song.id};path=/;samesite=lax;`;
  }

  pause() {
    this.isPlaying = false;
    this.currentSong.howl && this.currentSong.howl.pause();
  }

  stop() {
    this.isPlaying = false;
    this.currentSong.howl && this.currentSong.howl.stop();
  }

  next() {
    this.skipTo(this.currentIndex + 1);
  }

  previous() {
    this.skipTo(this.currentIndex - 1);
  }

  skipTo(index) {
    this.stop();

    if (index >= this.playlist.length) {
      index = 0;
    } else if (index < 0) {
      index = this.playlist.length - 1;
    }

    this.play(index);
  }

  seek(seconds) {
    this.currentSong.howl.seek(seconds);
  }
}

export default Player;
