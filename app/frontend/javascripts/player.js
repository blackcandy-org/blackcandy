import { Howl } from 'howler';
import { ajax } from '@rails/ujs';
import Playlist from './playlist';

class Player {
  currentIndex = 0;
  currentSong = {};
  selectedSongId = null;
  isPlaying = false;
  playlist = new Playlist();

  play(currentIndex) {
    if (this.playlist.length == 0) { return; }

    App.dispatchEvent(document, 'player:beforePlaying');

    const song = this.playlist.songs[currentIndex];
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

  seek(percent) {
    this.currentSong.howl.seek(this.currentSong.length * percent);
  }
}

export default Player;
