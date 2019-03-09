import { Controller } from 'stimulus';
import { formatDuration, toggleVisible } from '../helper';
import { ajax } from 'rails-ujs';

export default class extends Controller {
  static targets = [
    'header',
    'image',
    'songName',
    'artistName',
    'albumName',
    'songDuration',
    'songTimer',
    'progress',
    'playButton',
    'favoriteButton'
  ];

  initialize() {
    this.player = App.player;
    this._initPlaylist();

    this.player.onplay = () => {
      this._setPlayingStatus();
    };

    this.player.onend = () => {
      this.next();
    };
  }

  togglePlay(event) {
    toggleVisible(this.playButtonTargets, event.currentTarget);

    if (this.player.isPlaying()) {
      this.player.pause();
    } else {
      this.player.play(this.currentIndex);
    }
  }

  toggleFavorite() {
    if (!this.currentSong.howl) { return; }

    ajax({
      url: `/songs/${this.currentSong.id}/favorite`,
      type: 'post',
      success: () => {
        this.favoriteButtonTarget.classList.toggle('player__favorite');
      }
    });
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

  _setPlayingStatus() {
    this.imageTarget.src = this.currentSong.album_image_url;
    this.songNameTarget.textContent = this.currentSong.name;
    this.artistNameTarget.textContent = this.currentSong.artist_name;
    this.albumNameTarget.textContent = this.currentSong.album_name;
    this.songDurationTarget.textContent = formatDuration(this.currentSong.length);
    this.favoriteButtonTarget.classList.toggle('player__favorite', this.currentSong.is_favorited);

    this._showPlayerHeader();
    window.requestAnimationFrame(this._setProgress.bind(this));
  }

  _setProgress() {
    const seek = this.currentSong.howl ? this.currentSong.howl.seek() : 0;

    this.songTimerTarget.textContent = formatDuration(Math.round(seek));
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
        this.player.updatePlaylist(response);
      }
    });
  }

  _showPlayerHeader() {
    this.headerTarget.classList.add('player__header--show');
  }
}
