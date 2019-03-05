import { Controller } from 'stimulus';
import { formatDuration } from '../helper';
import { ajax } from 'rails-ujs';

export default class extends Controller {
  static targets = [
    'info',
    'image',
    'songName',
    'artistName',
    'albumName',
    'songDuration',
    'songTimer',
    'progress'
  ];

  initialize() {
    this.player = App.player;
    this._initPlaylist();

    this.player.onplay = () => {
      this._setPlayingStatus();
    };
  }

  togglePlay() {
    if (this.player.isPlaying()) {
      this.player.pause();
    } else {
      this.player.play(this.currentIndex);
    }
  }

  next() {
    this.player.next();
  }

  previous() {
    this.player.previous();
  }

  get currentIndex() {
    return this.player.currentIndex;
  }

  get currentSong() {
    return this.player.currentSong;
  }

  get isStoped() {
    return !!this.player.currentSong;
  }

  _setPlayingStatus() {
    this.imageTarget.src = this.currentSong.album_image_url;
    this.songNameTarget.textContent = this.currentSong.name;
    this.artistNameTarget.textContent = this.currentSong.artist_name;
    this.albumNameTarget.textContent = this.currentSong.album_name;
    this.songDurationTarget.textContent = formatDuration(this.currentSong.length);

    window.requestAnimationFrame(this._setProgress.bind(this));
  }

  _setProgress() {
    const seek = this.currentSong.howl.seek();

    this.songTimerTarget.textContent = formatDuration(seek);
    this.progressTarget.value = (seek / this.currentSong.length) * 100 || 0;

    if (this.player.isPlaying()) {
      window.requestAnimationFrame(this._setProgress.bind(this));
    }
  }

  _initPlaylist() {
    ajax({
      url: '/playlist/current',
      type: 'get',
      dataType: 'json',
      success: (response) => {
        this.player.playlist = response;
      }
    });
  }
}
