import { Controller } from 'stimulus';

import Player from '../player';
import { formatDuration } from '../helper';

const defaultVolume = 0.5;
const defaultAlbumImage = '/images/default_album.png';

export default class extends Controller {
  static targets = [
    'info',
    'mainButton',
    'volume',
    'albumImage',
    'songName',
    'artistName',
    'songDuration',
    'songTimer',
    'progress'
  ];

  initialize() {
    this.player = new Player(this.playlistController.playlistContent);

    this.player.onplay = () => {
      this._setPlayingStatus();
    };

    this.player.onpause = () => {
      this._setPauseStatus();
    };

    this.volumeTarget.value = localStorage.getItem('volume') || defaultVolume;
    // dispatch change event on player volume input.
    this.volumeTarget.dispatchEvent(new Event('change'));
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

  changeVolume(event) {
    this.player.volume(event.target.value);
  }

  get playlistController() {
    const playlist = document.querySelector('#js-playlist');
    return this.application.getControllerForElementAndIdentifier(playlist, 'playlist');
  }

  get currentIndex() {
    return this.player.currentIndex;
  }

  get currentSong() {
    return this.player.currentSong;
  }

  _setPlayingStatus() {
    this.infoTarget.classList.remove('hidden');
    this.mainButtonTarget.classList.add('playing');

    this.albumImageTarget.src = this.currentSong.album_image_url || defaultAlbumImage;
    this.songNameTarget.textContent = this.currentSong.name;
    this.artistNameTarget.textContent = this.currentSong.artist_name;
    this.songDurationTarget.textContent = formatDuration(this.currentSong.length);

    window.requestAnimationFrame(this._setProgress.bind(this));
    this.playlistController.showCurrentItem(this.currentIndex);
  }

  _setPauseStatus() {
    this.mainButtonTarget.classList.remove('playing');
  }

  _setProgress() {
    const seek = this.currentSong.howl.seek();

    this.songTimerTarget.textContent = formatDuration(seek);
    this.progressTarget.value = (seek / this.currentSong.length) * 100 || 0;

    if (this.player.isPlaying()) {
      window.requestAnimationFrame(this._setProgress.bind(this));
    }
  }
}
