import { Howl } from 'howler';
import { ajax } from '@rails/ujs';
import Playlist from './playlist';

class Player {
  isPlaying = false;
  playlist = new Playlist();

  play(currentIndex) {
    if (this.playlist.length == 0) { return; }

    App.dispatchEvent(document, 'player:beforePlaying');

    this.playlist.currentIndex = currentIndex;
    this.isPlaying = true;

    if (!this.currentSong.howl) {
      ajax({
        url: `/songs/${this.currentSong.id}`,
        type: 'get',
        dataType: 'json',
        success: (response) => {
          this.currentSong.howl = new Howl({
            src: [response.url],
            format: [response.format],
            html5: true,
            onplay: () => { App.dispatchEvent(document, 'player:playing'); },
            onpause: () => { App.dispatchEvent(document, 'player:pause'); },
            onend: () => { App.dispatchEvent(document, 'player:end'); },
            onstop: () => { App.dispatchEvent(document, 'player:stop'); }
          });

          Object.assign(this.currentSong, response);
          this.currentSong.howl.play();
        }
      });
    } else {
      this.currentSong.howl.play();
    }

    // keep track id of the current playing song
    document.cookie = `current_song_id=${this.currentSong.id};path=/;samesite=lax;`;
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
    this.skipTo(this.playlist.currentIndex + 1);
  }

  previous() {
    this.skipTo(this.playlist.currentIndex - 1);
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

  get currentSong() {
    return this.playlist.currentSong;
  }
}

export default Player;
